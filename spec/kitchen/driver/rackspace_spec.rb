# Encoding: UTF-8
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

require_relative '../../spec_helper'

require 'logger'
require 'stringio'
require 'rspec'
require 'kitchen'

describe Kitchen::Driver::Rackspace do
  let(:logged_output) { StringIO.new }
  let(:logger) { Logger.new(logged_output) }
  let(:config) { Hash.new }
  let(:state) { Hash.new }
  let(:platform_name) { 'ubuntu' }
  let(:default_rackspace_networks) do
    [
      '00000000-0000-0000-0000-000000000000',
      '11111111-1111-1111-1111-111111111111'
    ]
  end

  let(:instance) do
    double(
      name: 'potatoes',
      logger: logger,
      to_str: 'instance',
      platform: double(name: platform_name)
    )
  end

  let(:driver) do
    d = Kitchen::Driver::Rackspace.new(config)
    d.instance = instance
    d
  end

  before(:each) do
    ENV['RACKSPACE_USERNAME'] = 'user'
    ENV['RACKSPACE_API_KEY'] = 'key'
  end

  describe '#initialize'do
    before(:each) do
      allow(Fog).to receive(:timeout=)
    end

    default_networks = [
      '00000000-0000-0000-0000-000000000000',
      '11111111-1111-1111-1111-111111111111'
    ]

    context 'default options' do
      it 'defaults to v2 cloud' do
        expect(driver[:version]).to eq('v2')
      end

      it 'defaults to the smallest flavor size' do
        expect(driver[:flavor_id]).to eq('performance1-1')
      end

      it "defaults to local user's SSH public key" do
        path = File.expand_path('~/.ssh/id_rsa.pub')
        expect(File).to receive(:exist?).with(path).and_return(true)
        expect(driver[:public_key_path]).to eq(path)
      end

      it 'defaults to SSH with root user on port 22' do
        expect(driver[:username]).to eq('root')
        expect(driver[:port]).to eq('22')
      end

      it 'defaults to a random server name' do
        expect(driver[:server_name]).to be_a(String)
      end

      it 'defaults to the DFW region' do
        expect(driver[:rackspace_region]).to eq('dfw')
      end

      it 'defaults to username from $RACKSPACE_USERNAME' do
        expect(driver[:rackspace_username]).to eq('user')
      end

      it 'defaults to API key from $RACKSPACE_API_KEY' do
        expect(driver[:rackspace_api_key]).to eq('key')
      end

      it 'defaults to wait_for timeout of 600 seconds' do
        expect(driver[:wait_for]).to eq(600)
        expect(Fog).to have_received(:timeout=).with(600)
      end

      it 'defaults to the standard Rackspace networks' do
        expect(driver[:networks]).to eq(default_networks)
      end
    end

    platforms = {
      'ubuntu-12.04' => 'a4286a42-137c-46ce-a796-dbd2b12a078c',
      'ubuntu-12' => 'a4286a42-137c-46ce-a796-dbd2b12a078c',
      'ubuntu' => 'bb02b1a3-bc77-4d17-ab5b-421d89850fca',
      'centos-5.10' => '9522c27d-51d9-44ee-8eb3-fb7b14fd4042',
      'centos-5' => '9522c27d-51d9-44ee-8eb3-fb7b14fd4042',
      'centos' => '592c879e-f37d-43e6-8b54-8c2d97cf04d4'
    }
    platforms.each do |platform, id|
      context "name is #{platform}" do
        let(:platform_name) { platform }

        it 'defaults to the correct image ID' do
          expect(driver[:image_id]).to eq(id)
        end
      end
    end

    context 'overridden options' do
      config = {
        image_id: '22',
        flavor_id: '33',
        public_key_path: '/tmp',
        username: 'admin',
        port: '2222',
        server_name: 'puppy',
        rackspace_region: 'ord',
        wait_for: 1200
      }

      let(:config) { config }

      config.each do |key, value|
        it "it uses the overridden #{key} option" do
          expect(driver[key]).to eq(value)
        end
      end

      it 'sets the new wait_for variable' do
        expect(driver[:wait_for]).to eq(1200)
        expect(Fog).to have_received(:timeout=).with(1200)
      end
    end

    context 'OpenStack environment variables' do
      before(:each) do
        ENV.delete('RACKSPACE_USERNAME')
        ENV.delete('RACKSPACE_API_KEY')
        ENV['OS_USERNAME'] = 'os_user'
        ENV['OS_PASSWORD'] = 'os_pass'
      end

      it 'gets to username from $OS_USERNAME' do
        expect(driver[:rackspace_username]).to eq('os_user')
      end

      it 'gets to API key from $OS_PASSWORD' do
        expect(driver[:rackspace_api_key]).to eq('os_pass')
      end
    end
  end

  describe '#create' do
    let(:server) do
      double(id: 'test123', wait_for: true,
             public_ip_address: '1.2.3.4')
    end
    let(:driver) do
      config[:wait_for] = '1200'
      d = Kitchen::Driver::Rackspace.new(config)
      d.instance = instance
      allow(d).to receive(:default_name).and_return('a_monkey!')
      allow(d).to receive(:create_server).and_return(server)
      allow(d).to receive(:wait_for_sshd).with('1.2.3.4').and_return(true)
      d
    end

    context 'username and API key only provided' do
      let(:config) do
        {
          rackspace_username: 'hello',
          rackspace_api_key: 'world',
          wait_for: 1200
        }
      end

      it 'generates a server name in the absence of one' do
        driver.create(state)
        expect(driver[:server_name]).to eq('a_monkey!')
      end

      it 'gets a proper server ID' do
        driver.create(state)
        expect(state[:server_id]).to eq('test123')
      end

      it 'gets a proper hostname (IP)' do
        driver.create(state)
        expect(state[:hostname]).to eq('1.2.3.4')
      end
    end

  end

  describe '#destroy' do
    let(:server_id) { '12345' }
    let(:hostname) { 'example.com' }
    let(:state) { { server_id: server_id, hostname: hostname } }
    let(:server) { double(nil?: false, destroy: true) }
    let(:servers) { double(get: server) }
    let(:compute) { double(servers: servers) }

    let(:driver) do
      d = Kitchen::Driver::Rackspace.new(config)
      d.instance = instance
      allow(d).to receive(:compute).and_return(compute)
      d
    end

    context 'a live server that needs to be destroyed' do
      it 'destroys the server' do
        expect(state).to receive(:delete).with(:server_id)
        expect(state).to receive(:delete).with(:hostname)
        driver.destroy(state)
      end
    end

    context 'no server ID present' do
      let(:state) { Hash.new }

      it 'does nothing' do
        allow(driver).to receive(:compute)
        expect(driver).to_not receive(:compute)
        expect(state).to_not receive(:delete)
        driver.destroy(state)
      end
    end

    context 'a server that was already destroyed' do
      let(:servers) do
        s = double('servers')
        allow(s).to receive(:get).with('12345').and_return(nil)
        s
      end
      let(:compute) { double(servers: servers) }
      let(:driver) do
        d = Kitchen::Driver::Rackspace.new(config)
        d.instance = instance
        allow(d).to receive(:compute).and_return(compute)
        d
      end

      it 'does not try to destroy the server again' do
        allow_message_expectations_on_nil
        driver.destroy(state)
      end
    end
  end

  describe '#compute' do
    let(:config) do
      {
        rackspace_username: 'monkey',
        rackspace_api_key: 'potato',
        rackspace_region: 'ord'
      }
    end

    context 'all requirements provided' do
      it 'creates a new compute connection' do
        allow(Fog::Compute).to receive(:new) { |arg| arg }
        res = config.merge(provider: 'Rackspace', version: 'v2')
        expect(driver.send(:compute)).to eq(res)
      end
    end

    context 'no username provided' do
      let(:config) do
        { rackspace_username: nil, rackspace_api_key: '1234' }
      end

      it 'raises an error' do
        expect { driver.send(:compute) }.to raise_error(ArgumentError)
      end
    end

    context 'no API key provided' do
      let(:config) do
        { rackspace_username: 'monkey', rackspace_api_key: nil }
      end

      it 'raises an error' do
        expect { driver.send(:compute) }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#create_server' do
    let(:config) do
      {
        server_name: 'hello',
        image_id: 'there',
        flavor_id: 'captain',
        public_key_path: 'tarpals',
        networks: default_rackspace_networks
      }
    end
    before(:each) do
      @expected = config.merge(name: config[:server_name])
      @expected.delete_if do |k, _|
        k == :server_name
      end
    end
    let(:servers) do
      s = double('servers')
      allow(s).to receive(:bootstrap) { |arg| arg }
      s
    end
    let(:compute) { double(servers: servers) }
    let(:driver) do
      d = Kitchen::Driver::Rackspace.new(config)
      d.instance = instance
      allow(d).to receive(:compute).and_return(compute)
      d
    end

    it 'creates the server using a compute connection' do
      expect(driver.send(:create_server)).to eq(@expected)
    end

    context 'additional networks specified' do
      let(:server_id) { '12345' }
      let(:server) do
        double(id: 'test123', wait_for: true,
               public_ip_address: '1.2.3.4')
      end
      let(:hostname) { 'example.com' }
      let(:servers_double) { double('servers', bootstrap: server) }
      let(:compute_double) { double(Fog::Compute, servers: servers_double) }
      let(:state) { { server_id: server_id, hostname: hostname } }
      let(:driver) do
        d = Kitchen::Driver::Rackspace.new(config)
        allow(d).to receive(:wait_for_sshd).with('1.2.3.4').and_return(true)
        d.instance = instance
        allow(Fog::Compute).to receive(:new).and_return(compute_double)
        d
      end
      let(:user_specified_network) { 'bob_dole' }
      let(:config) do
        {
          rackspace_username: 'monkey',
          rackspace_api_key: 'potato',
          rackspace_region: 'ord',
          networks: [user_specified_network]
        }
      end
      it 'has the user specified network, plus default Rackspace networks' do
        driver.create(state)
        expect(servers_double).to have_received(:bootstrap) do |arg|
          expect(arg[:networks][2]).to eq user_specified_network
        end
      end
    end
  end

  describe '#default_name' do
    before(:each) do
      allow(Etc).to receive(:getlogin).and_return('user')
      allow(Socket).to receive(:gethostname).and_return('host')
    end

    it 'generates a name' do
      expect(driver.default_name).to match(
        /^potatoes-user-host-/)
    end
  end
end
