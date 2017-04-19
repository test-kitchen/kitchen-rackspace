# Encoding: UTF-8
#
# Author:: Jonathan Hartman (<j@p4nt5.com>)
#
# Copyright (C) 2013-2015, Jonathan Hartman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'benchmark'
require 'fog'
require 'kitchen'
require 'etc'
require 'socket'
require 'buff/extensions'

module Kitchen
  module Driver
    # Rackspace driver for Kitchen.
    #
    # @author Jonathan Hartman <j@p4nt5.com>
    class Rackspace < Kitchen::Driver::SSHBase
      default_config :version, 'v2'
      default_config :flavor_id, 'performance1-1'
      default_config :username, 'root'
      default_config :port, '22'
      default_config :rackspace_region, 'dfw'
      default_config :wait_for, 600
      default_config :no_ssh_tcp_check, false
      default_config :no_ssh_tcp_check_sleep, 120
      default_config :rackconnect_wait, false
      default_config :servicelevel_wait, false
      default_config :no_passwd_lock, false
      default_config :servicenet, true
      default_config(:image_id, &:default_image)
      default_config(:server_name, &:default_name)
      default_config :networks, nil
      default_config :connect_public_net, true
      default_config :ssh_network_name, nil

      default_config :public_key_path do
        [
          File.expand_path('~/.ssh/id_rsa.pub'),
          File.expand_path('~/.ssh/id_dsa.pub'),
          File.expand_path('~/.ssh/identity.pub'),
          File.expand_path('~/.ssh/id_ecdsa.pub')
        ].find { |path| File.exist?(path) }
      end

      default_config :rackspace_username do
        ENV['RACKSPACE_USERNAME'] || ENV['OS_USERNAME']
      end

      default_config :rackspace_api_key do
        ENV['RACKSPACE_API_KEY'] || ENV['OS_PASSWORD']
      end

      required_config :rackspace_username
      required_config :rackspace_api_key
      required_config :image_id
      required_config :public_key_path

      def initialize(config)
        super
        Fog.timeout = config[:wait_for].to_i
      end

      def create(state)
        server = create_server
        state[:server_id] = server.id
        info("Rackspace instance <#{state[:server_id]}> created.")
        rackconnect_check(server) if config[:rackconnect_wait]
        servicelevel_check(server) if config[:servicelevel_wait]
        server.update # refresh accessIPv4 with new IP
        state[:hostname] = hostname(server)
        tcp_check(state)
      rescue Fog::Errors::Error, Excon::Errors::Error => ex
        raise ActionFailed, ex.message
      end

      def destroy(state)
        return if state[:server_id].nil?

        server = compute.servers.get(state[:server_id])
        server.destroy unless server.nil?
        info("Rackspace instance <#{state[:server_id]}> destroyed.")
        state.delete(:server_id)
        state.delete(:hostname)
      end

      def default_image
        images[instance.platform.name]
      end

      # Generate what should be a unique server name up to 63 total chars
      # Base name:    15
      # Username:     15
      # Hostname:     23
      # Random string: 7
      # Separators:    3
      # ================
      # Total:        63
      def default_name
        [
          instance.name.gsub(/\W/, '')[0..14],
          (Etc.getlogin || 'nologin').gsub(/\W/, '')[0..14],
          Socket.gethostname.gsub(/\W/, '')[0..22],
          Array.new(7) { rand(36).to_s(36) }.join
        ].join('-')
      end

      private def server_config
        return @server_config if defined?(@server_config)
        @server_config = { name: config[:server_name], networks: networks }
        [:image_id, :flavor_id, :public_key_path, :no_passwd_lock].each do |opt|
          @server_config[opt] = config[opt]
        end
        # see @note on bootstrap def about rackconnect
        no_passwd_lock = config[:rackconnect_wait] || config[:servicelevel_wait]
        @server_config[:no_passwd_lock] = no_passwd_lock if no_passwd_lock
        @server_config[:ssh_ip_address] = proc { |server| hostname(server) }
        @server_config
      end

      private def compute
        opts = config.slice(:version, :rackspace_username,
                            :rackspace_api_key, :rackspace_region)
        Fog::Compute.new({ provider: 'Rackspace' }.merge(opts))
      end

      private def create_server
        compute.servers.new(server_config).tap do |server|
          server.save(networks: server_config[:networks])
          puts 'Waiting for server build to complete:'
          server.wait_for do
            print '.'
            ready?
          end
          # This needs to happen before any ssh connections are attempted in
          # order to install the root user ssh keys.
          puts '(starting server auth setup)'
          server.setup(password: server.password)
          puts '(server ready)'
        end
      end

      private def images
        @images ||= begin
          json_file = File.expand_path('../../../../data/images.json', __FILE__)
          JSON.parse(IO.read(json_file))
        end
      end

      private def tcp_check(state)
        # allow driver config to bypass SSH tcp check -- because
        # it doesn't respect ssh_config values that might be required
        wait_for_sshd(state[:hostname]) unless config[:no_ssh_tcp_check]
        sleep(config[:no_ssh_tcp_check_sleep]) if config[:no_ssh_tcp_check]
        puts '(ssh ready)'
      end

      private def rackconnect_check(server)
        server.wait_for \
          { metadata.all['rackconnect_automation_status'] == 'DEPLOYED' }
        puts '(rackconnect automation complete)'
      end

      private def servicelevel_check(server)
        server.wait_for \
          { metadata.all['rax_service_level_automation'] == 'Complete' }
        puts '(service level automation complete)'
      end

      private def hostname(server)
        if config[:ssh_network_name]
          server.addresses[config[:ssh_network_name]].first['addr']
        elsif config[:connect_public_net] || config[:servicenet] == false
          server.public_ip_address
        else
          server.private_ip_address
        end
      end

      private def public_network
        # Returns nil if no public ip address should be provisioned
        '00000000-0000-0000-0000-000000000000' if config[:connect_public_net]
      end

      private def service_network
        '11111111-1111-1111-1111-111111111111' if config[:servicenet]
      end

      private def additional_networks
        # If only one additional network is specified as a string in the yaml
        # instead of as an array, convert it to an array.
        (config[:networks] || []).to_a
      end

      private def networks
        # The .compact call gets rid of nil public_network
        [service_network, public_network].concat(additional_networks).compact
      end
    end
  end
end
