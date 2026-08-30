require "benchmark" unless defined?(Benchmark)
require "fog/rackspace"
require "kitchen"
require "etc" unless defined?(Etc)
require "socket" unless defined?(Socket)
require "json" unless defined?(JSON)
require "time" unless defined?(Time.now.iso8601)
require_relative "rackspace_version"

module Kitchen
  # Test Kitchen's driver plugins.
  module Driver
    # Test Kitchen driver for Rackspace Cloud Servers.
    #
    # Creates a Cloud Server for the instance under test, waits for it to
    # become reachable, and destroys it afterwards. Talking to the server is
    # the transport's job; this driver only tells Test Kitchen where it is and
    # who to log in as.
    #
    # Rackspace can run post-build automation -- RackConnect and Managed
    # Service Level -- that keeps modifying a server after it first reports
    # +ready+, including changing its public address. Set +rackconnect_wait+
    # or +servicelevel_wait+ so the driver waits for that to finish before
    # handing the server over, or the transport will connect to an address
    # that is about to change.
    class Rackspace < Kitchen::Driver::Base
      kitchen_driver_api_version 2

      plugin_version Kitchen::Driver::RACKSPACE_VERSION

      # Server states Rackspace reports for a server that is up and reachable.
      LIVE_STATES = %w{ACTIVE}.freeze

      default_config :version, "v2"
      default_config :flavor_id, "general1-2"
      default_config :username, "root"
      default_config :port, "22"
      default_config :wait_for, 600
      default_config :no_ssh_tcp_check, false
      default_config :no_ssh_tcp_check_sleep, 120
      default_config :rackconnect_wait, false
      default_config :servicelevel_wait, false
      default_config :no_passwd_lock, false
      default_config :servicenet, false
      default_config(:image_id, &:default_image)
      default_config(:server_name, &:default_name)
      default_config :networks, nil
      default_config :user_data, nil
      default_config :config_drive, true

      default_config :public_key_path do
        [
          File.expand_path("~/.ssh/id_rsa.pub"),
          File.expand_path("~/.ssh/id_dsa.pub"),
          File.expand_path("~/.ssh/identity.pub"),
          File.expand_path("~/.ssh/id_ecdsa.pub"),
        ].find { |path| File.exist?(path) }
      end

      default_config :rackspace_username do
        ENV["RACKSPACE_USERNAME"] || ENV["OS_USERNAME"]
      end

      default_config :rackspace_api_key do
        ENV["RACKSPACE_API_KEY"] || ENV["OS_PASSWORD"]
      end

      default_config :rackspace_region do
        ENV["RACKSPACE_REGION"] || ENV["OS_REGION_NAME"] || "dfw"
      end

      required_config :rackspace_username
      required_config :rackspace_api_key
      required_config :image_id
      required_config :public_key_path

      # Sets up the driver and applies +wait_for+ as fog's global timeout.
      #
      # +Fog.timeout+ is process-wide, so the last driver constructed wins if
      # several are in play.
      #
      # @param config [Hash] the driver configuration
      def initialize(config)
        super
        Fog.timeout = config[:wait_for].to_i
      end

      # Creates the Cloud Server and waits until it can be logged into.
      #
      # Waits for the server to report ready, then optionally for RackConnect
      # and Managed Service Level automation, then for the transport to accept
      # a connection.
      #
      # @param state [Hash] mutable instance state; gains +server_id+,
      #   +hostname+, +username+, and +port+
      # @return [void]
      # @raise [Kitchen::ActionFailed] if the Rackspace API rejects the build
      def create(state)
        server = create_server
        state[:server_id] = server.id
        info("Rackspace instance <#{state[:server_id]}> created.")
        server.wait_for { ready? }
        puts "(server ready)"
        rackconnect_check(server) if config[:rackconnect_wait]
        servicelevel_check(server) if config[:servicelevel_wait]
        state[:hostname] = hostname(server)
        state[:username] = config[:username]
        state[:port] = config[:port] if config[:port]
        tcp_check(state)
      rescue Fog::Errors::Error, Excon::Errors::Error => ex
        raise ActionFailed, ex.message
      end

      # Destroys the Cloud Server, if one was created.
      #
      # @param state [Hash] mutable instance state; +server_id+ and +hostname+
      #   are removed
      # @return [void]
      def destroy(state)
        return if state[:server_id].nil?

        server = compute.servers.get(state[:server_id])
        server.destroy unless server.nil?
        info("Rackspace instance <#{state[:server_id]}> destroyed.")
        state.delete(:server_id)
        state.delete(:hostname)
      end

      # Looks up the base image for the platform under test.
      #
      # @return [String, nil] the Rackspace image ID, or nil when the platform
      #   is not one the bundled image list knows about, in which case
      #   +image_id+ must be set explicitly
      def default_image
        images[instance.platform.name]
      end

      # Generates a server name that is unique per run and fits Rackspace's
      # 63-character limit.
      #
      # The budget is spent as base name 15, username 15, hostname 23, random
      # suffix 7, and three separators, for 63 exactly. Each part is stripped
      # of non-word characters and truncated to its share, so a long login or
      # hostname cannot push the result over.
      #
      # @return [String] e.g. +default-alice-buildbox01-x7f2p9q+
      def default_name
        [
          instance.name.gsub(/\W/, "")[0..14],
          (Etc.getlogin || "nologin").gsub(/\W/, "")[0..14],
          Socket.gethostname.gsub(/\W/, "")[0..22],
          Array.new(7) { rand(36).to_s(36) }.join,
        ].join("-")
      end

      # Reports what Rackspace currently thinks of the server.
      #
      # @param state [Hash] instance state naming the server
      # @return [Hash] a Test Kitchen status hash, or the base implementation's
      #   answer when there is no server or Rackspace does not know it
      def status(state)
        return super unless state[:server_id]

        server = lookup_server(state[:server_id])
        return super unless server

        {
          live: LIVE_STATES.include?(server.state),
          state: server.state,
          source: "driver",
          resource_id: state[:server_id],
          message: "Rackspace reports the server as #{server.state}",
          checked_at: Time.now.utc.iso8601,
        }
      end

      # Checks the configuration for the mistakes that only show up as a
      # confusing failure part way through +create+.
      #
      # @param state [Hash] instance state; accepted for the Test Kitchen hook
      #   signature and not read
      # @return [Boolean] true when a problem was reported
      def doctor(state) # rubocop:disable Lint/UnusedMethodArgument
        problems = []

        if config[:image_id].nil?
          problems << "No image_id is set and #{instance.platform.name} is not " \
                      "in the bundled image list. Set image_id explicitly."
        end

        if config[:public_key_path].nil?
          problems << "No public key was found in ~/.ssh. Set public_key_path " \
                      "to the key Rackspace should install on the server."
        end

        problems.concat(credential_problems)

        problems.each { |problem| warn(problem) }
        !problems.empty?
      end

      private

      # Confirms the configured credentials can actually talk to Rackspace,
      # which is cheaper to learn here than half way through a converge.
      #
      # Listing servers is the cheapest authenticated call fog-rackspace
      # offers: +GET /servers+ returns only an ID and a name per server, and
      # it exercises the compute endpoint for the configured region rather
      # than just the identity endpoint.
      #
      # @return [Array<String>] a problem description, or an empty array
      def credential_problems
        compute.servers.all
        []
      rescue Fog::Errors::Error, Excon::Errors::Error => e
        ["Rackspace rejected the configured credentials for region " \
         "#{config[:rackspace_region]}: #{e.message}"]
      end

      # Looks a server up without turning a missing one into a failure.
      #
      # @param server_id [String] the Rackspace server ID
      # @return [Fog::Compute::RackspaceV2::Server, nil] the server, or nil
      #   when Rackspace does not know it or cannot be reached
      def lookup_server(server_id)
        compute.servers.get(server_id)
      rescue Fog::Errors::Error, Excon::Errors::Error
        nil
      end

      # Builds the fog compute connection from the configured credentials.
      #
      # @return [Fog::Compute] a Rackspace compute connection
      def compute
        server_def = { provider: "Rackspace" }
        opts = %i{version rackspace_username rackspace_api_key
                  rackspace_region}
        opts.each do |opt|
          server_def[opt] = config[opt]
        end
        Fog::Compute.new(server_def)
      end

      # Bootstraps the Cloud Server from the configured options.
      #
      # RackConnect and Managed Service Level both need the root password left
      # unlocked to do their work, so +no_passwd_lock+ is forced on whenever
      # either wait is requested, regardless of how it was configured.
      #
      # @note fog's +bootstrap+ calls +Server#setup+, which rescues
      #   +Errno::ECONNREFUSED+ and retries forever, one second apart. A server
      #   that never opens port 22 hangs here rather than failing, and
      #   +wait_for+ does not bound it.
      #
      # @return [Fog::Compute::RackspaceV2::Server] the newly built server
      def create_server
        server_def = { name: config[:server_name], networks: }
        %i{image_id flavor_id public_key_path no_passwd_lock user_data config_drive}.each do |opt|
          server_def[opt] = config[opt]
        end
        # RackConnect and Managed Service Level need the root password left
        # unlocked; see the note above.
        no_passwd_lock = config[:rackconnect_wait] || config[:servicelevel_wait]
        server_def[:no_passwd_lock] = no_passwd_lock if no_passwd_lock
        compute.servers.bootstrap(server_def)
      end

      # The bundled platform-name to image-ID map.
      #
      # @return [Hash{String => String}] parsed from +data/images.json+
      def images
        @images ||= begin
          json_file = File.expand_path("../../../data/images.json", __dir__)
          JSON.parse(IO.read(json_file))
        end
      end

      # Waits until the server will accept a login.
      #
      # The TCP check does not honour +ssh_config+, which some setups need, so
      # +no_ssh_tcp_check+ swaps the check for a fixed sleep of
      # +no_ssh_tcp_check_sleep+ seconds instead.
      #
      # @param state [Hash] instance state describing how to connect
      # @return [void]
      def tcp_check(state)
        # allow driver config to bypass SSH tcp check -- because
        # it doesn't respect ssh_config values that might be required
        wait_for_sshd(state) unless config[:no_ssh_tcp_check]
        sleep(config[:no_ssh_tcp_check_sleep]) if config[:no_ssh_tcp_check]
        puts "(ssh ready)"
      end

      # Blocks until the configured transport can connect to the instance.
      #
      # Kitchen::Driver::SSHBase used to supply this; the configured transport
      # knows how to wait for the instance to accept connections.
      #
      # @param state [Hash] instance state describing how to connect
      # @return [void]
      def wait_for_sshd(state)
        instance.transport.connection(state, &:wait_until_ready)
      end

      # Waits for RackConnect automation to finish.
      #
      # The server is refreshed afterwards, because RackConnect assigns a new
      # public address as part of its work and the stale one would otherwise
      # be handed to the transport.
      #
      # @param server [Fog::Compute::RackspaceV2::Server] the server to poll
      # @return [void]
      def rackconnect_check(server)
        server.wait_for \
          { metadata.all["rackconnect_automation_status"] == "DEPLOYED" }
        puts "(rackconnect automation complete)"
        server.update # refresh accessIPv4 with new IP
      end

      # Waits for Managed Service Level automation to finish.
      #
      # @param server [Fog::Compute::RackspaceV2::Server] the server to poll
      # @return [void]
      def servicelevel_check(server)
        server.wait_for \
          { metadata.all["rax_service_level_automation"] == "Complete" }
        puts "(service level automation complete)"
      end

      # Picks the address Test Kitchen should connect to.
      #
      # @param server [Fog::Compute::RackspaceV2::Server] the built server
      # @return [String] the private address when +servicenet+ is set,
      #   otherwise the public one
      def hostname(server)
        if config[:servicenet] == false
          server.public_ip_address
        else
          server.private_ip_address
        end
      end

      # Builds the network list for the new server.
      #
      # Rackspace's PublicNet and ServiceNet have fixed, well-known IDs. Any
      # configured networks are added to those two rather than replacing them,
      # since dropping PublicNet would leave the server unreachable.
      #
      # @return [Array<String>, nil] network IDs, or nil to let Rackspace
      #   apply its own defaults
      def networks
        base_nets = %w{
          00000000-0000-0000-0000-000000000000
          11111111-1111-1111-1111-111111111111
        }
        config[:networks] ? base_nets + config[:networks] : nil
      end
    end
  end
end
