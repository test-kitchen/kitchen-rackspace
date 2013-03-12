# -*- encoding: utf-8 -*-
#
# Author:: Jonathan Hartman (<j@p4nt5.com>)
#
# Copyright (C) 2013, Jonathan Hartman
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
      default_config :version,          'v2'
      default_config :image_id,         '8a3a9f96-b997-46fd-b7a8-a9e740796ffd'
      default_config :flavor_id,        '2'
      default_config :name,             nil
      default_config :public_key_path,  File.expand_path('~/.ssh/id_dsa.pub')
      default_config :username,         'root'
      default_config :port,             '22'

      def create(state)
        if not config[:name]
          # Generate what should be a unique server name
          config[:name] = "#{instance.name}-#{Etc.getlogin}-" +
            "#{Socket.gethostname}-#{Array.new(8){rand(36).to_s(36)}.join}"
        end
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

      private

      def compute
        Fog::Compute.new(
          :provider           => "Rackspace",
          :version            => config[:version],
          :rackspace_username => config[:rackspace_username],
          :rackspace_api_key  => config[:rackspace_api_key]
        )
      end

      def create_server
        compute.servers.bootstrap(
          :name             => config[:name],
          :image_id         => config[:image_id],
          :flavor_id        => config[:flavor_id],
          :public_key_path  => config[:public_key_path]
        )
      end
    end
  end
end

# vim: ai et ts=2 sts=2 sw=2 ft=ruby
