# -*- encoding: utf-8 -*-
#
# Author:: Jonathan Hartman (<j@p4nt5.com>)
#
# Copyright (C) 2013-2014, Jonathan Hartman
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
      default_config :rackspace_region, nil

      default_config :image_id do |driver|
        driver.default_image
      end

      default_config :server_name do |driver|
        driver.default_name
      end

      default_config :public_key_path do |driver|
        [
          File.expand_path('~/.ssh/id_rsa.pub'),
          File.expand_path('~/.ssh/id_dsa.pub'),
          File.expand_path('~/.ssh/identity.pub'),
          File.expand_path('~/.ssh/id_ecdsa.pub'),
        ].find { |path| File.exists?(path) }
      end

      default_config :rackspace_username do |driver|
        ENV['RACKSPACE_USERNAME'] || ENV['OS_USERNAME']
      end

      default_config :rackspace_api_key do |driver|
        ENV['RACKSPACE_API_KEY'] || ENV['OS_PASSWORD']
      end

      required_config :rackspace_username
      required_config :rackspace_api_key
      required_config :image_id
      required_config :public_key_path

      def create(state)
        server = create_server
        state[:server_id] = server.id
        info("Rackspace instance <#{state[:server_id]}> created.")
        server.wait_for { ready? } ; puts "(server ready)"
        state[:hostname] = server.public_ip_address
        wait_for_sshd(state[:hostname]) ; puts "(ssh ready)"
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

      def default_name
        # Generate what should be a unique server name
        rand_str = Array.new(8) { rand(36).to_s(36) }.join
        "#{instance.name}-#{Etc.getlogin}-#{Socket.gethostname}-#{rand_str}"
      end

      private

      def compute
        server_def = {
          :provider           => "Rackspace",
          :version            => config[:version],
          :rackspace_username => config[:rackspace_username],
          :rackspace_api_key  => config[:rackspace_api_key]
        }
        if config[:rackspace_region]
          server_def[:rackspace_region] = config[:rackspace_region]
        end
        Fog::Compute.new(server_def)
      end

      def create_server
        compute.servers.bootstrap(
          :name             => config[:server_name],
          :image_id         => config[:image_id],
          :flavor_id        => config[:flavor_id],
          :public_key_path  => config[:public_key_path]
        )
      end

      def images
        @images ||= begin
          json_file = File.expand_path(
            File.join(%w{.. .. .. .. data images.json}),
            __FILE__
          )
          JSON.load(IO.read(json_file))
        end
      end
    end
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby
