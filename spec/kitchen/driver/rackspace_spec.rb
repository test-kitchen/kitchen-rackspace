# Encoding: UTF-8

require_relative '../../spec_helper'
require_relative '../../../lib/kitchen/driver/rackspace'

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
  let(:default_networks) { nil }
  let(:instance_name) { 'potatoes' }

  let(:instance) do
    double(
      name: instance_name,
      logger: logger,
      to_str: 'instance',
      platform: double(name: platform_name)
    )
  end

  let(:driver) { described_class.new(config) }

  before(:each) do
    allow_any_instance_of(described_class).to receive(:instance)
      .and_return(instance)
    ENV['RACKSPACE_USERNAME'] = 'user'
    ENV['RACKSPACE_API_KEY'] = 'key'
  end

  describe '#initialize'do
    before(:each) do
      allow(Fog).to receive(:timeout=)
    end

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

      it 'defaults the SSH TCP bypassing to false' do
        expect(driver[:no_ssh_tcp_check]).to eq(false)
      end

      it 'defaults the TCP bypass sleep time to 120 seconds' do
        expect(driver[:no_ssh_tcp_check_sleep]).to eq(120)
      end

      it 'defaults to the standard Rackspace networks' do
        expect(driver[:networks]).to eq(default_networks)
      end

      it 'defaults to not waiting for rackconnect' do
        expect(driver[:rackconnect_wait]).to eq(false)
      end

      it 'defaults to not waiting for managed service level' do
        expect(driver[:servicelevel_wait]).to eq(false)
      end

      it 'defaults to the public ip address' do
        expect(driver[:servicenet]).to eq(false)
      end

      it 'defaults to no_passwd_lock as false' do
        expect(driver[:no_passwd_lock]).to eq(false)
      end
    end

    platforms = {
      'ubuntu-12.04' => '973775ab-0653-4ef8-a571-7a2777787735',
      'ubuntu-12' => '973775ab-0653-4ef8-a571-7a2777787735',
      'ubuntu' => '658a7d3b-4c58-4e29-b339-2509cca0de10',
      'centos-5' => 'fdaf64c7-d9f3-446c-bd7c-70349305ae91',
      'centos' => '6595f1b7-e825-4bd2-addc-c7b1c803a37f'
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
        wait_for: 1200,
        rackconnect_wait: true,
        servicelevel_wait: true,
        use_private_ip_address: true
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
    let(:config) { super().merge(wait_for: '1200') }
    let(:server) do
      double(id: 'test123',
             wait_for: true,
             public_ip_address: '1.2.3.4')
    end

    before(:each) do
      {
        default_name: 'a_monkey!',
        create_server: server,
        tcp_check: true
      }.each do |k, v|
        allow_any_instance_of(described_class).to receive(k).and_return(v)
      end
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

      it 'calls tcp_check' do
        expect(driver).to receive(:tcp_check)
        driver.create(state)
      end
    end

    context 'a Fog error' do
      before(:each) do
        allow_any_instance_of(described_class).to receive(:create_server)
          .and_raise(Fog::Errors::Error, 'Uhoh')
      end

      it 're-raises the error' do
        expect { driver.create(state) }.to raise_error(Kitchen::ActionFailed,
                                                       'Uhoh')
      end
    end
  end

  describe '#create and rackconnect_wait' do
    let(:server) do
      double(id: 'test123',
             wait_for: true,
             public_ip_address: '1.2.3.4',
             private_ip_address: '10.9.8.7',
             update: nil)
    end

    before(:each) do
      {
        default_name: 'a_monkey!',
        create_server: server,
        tcp_check: true
      }.each do |k, v|
        allow_any_instance_of(described_class).to receive(k).and_return(v)
      end
    end

    context 'username and API key only provided' do
      let(:config) do
        {
          rackspace_username: 'hello',
          rackspace_api_key: 'world',
          wait_for: 1200,
          rackconnect_wait: true
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

      it 'calls tcp_check' do
        expect(driver).to receive(:tcp_check)
        driver.create(state)
      end

      it 'calls rackconnect_check ' do
        expect(driver).to receive(:rackconnect_check)
        driver.create(state)
      end

      it 'rackconnect_check waits for rackconnect_automation' do
        expect(server).to receive(:wait_for)
        driver.send(:rackconnect_check, server)
      end
    end
  end

  describe '#create and servicelevel_wait' do
    let(:server) do
      double(id: 'test123',
             wait_for: true,
             public_ip_address: '1.2.3.4',
             private_ip_address: '10.9.8.7',
             update: nil)
    end

    before(:each) do
      {
        default_name: 'a_monkey!',
        create_server: server,
        tcp_check: true
      }.each do |k, v|
        allow_any_instance_of(described_class).to receive(k).and_return(v)
      end
    end

    context 'username and API key only provided' do
      let(:config) do
        {
          rackspace_username: 'hello',
          rackspace_api_key: 'world',
          wait_for: 1200,
          servicelevel_wait: true
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

      it 'calls tcp_check' do
        expect(driver).to receive(:tcp_check)
        driver.create(state)
      end

      it 'calls servicelevel_check ' do
        expect(driver).to receive(:servicelevel_check)
        driver.create(state)
      end

      it 'servicelevel_check waits for managed service level automation' do
        expect(server).to receive(:wait_for)
        driver.send(:servicelevel_check, server)
      end
    end
  end

  describe '#create and use_private_ip_address' do
    let(:server) do
      double(id: 'test123',
             wait_for: true,
             public_ip_address: '1.2.3.4',
             private_ip_address: '10.9.8.7')
    end

    before(:each) do
      {
        default_name: 'a_monkey!',
        create_server: server,
        tcp_check: true
      }.each do |k, v|
        allow_any_instance_of(described_class).to receive(k).and_return(v)
      end
    end

    context 'username and API key only provided' do
      let(:config) do
        {
          rackspace_username: 'hello',
          rackspace_api_key: 'world',
          wait_for: 1200,
          servicenet: true
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

      it 'gets a private ip as the hostname' do
        driver.create(state)
        expect(state[:hostname]).to eq('10.9.8.7')
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

    before(:each) do
      allow_any_instance_of(described_class).to receive(:compute)
        .and_return(compute)
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

      before(:each) do
        allow_any_instance_of(described_class).to receive(:compute)
          .and_return(compute)
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
        no_passwd_lock: false,
        networks: default_networks
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

    before(:each) do
      allow_any_instance_of(described_class).to receive(:compute)
        .and_return(compute)
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
      let(:servers) { double('servers', bootstrap: server) }
      let(:compute) { double(Fog::Compute, servers: servers) }
      let(:state) { { server_id: server_id, hostname: hostname } }
      let(:user_specified_network) { 'bob_dole' }
      let(:config) do
        {
          rackspace_username: 'monkey',
          rackspace_api_key: 'potato',
          rackspace_region: 'ord',
          networks: [user_specified_network]
        }
      end

      before(:each) do
        { wait_for_sshd: true, compute: compute }.each do |k, v|
          allow_any_instance_of(described_class).to receive(k).and_return(v)
        end
      end

      it 'has the user specified network, plus default Rackspace networks' do
        driver.send(:create_server)
        expect(servers).to have_received(:bootstrap) do |arg|
          expect(arg[:networks][2]).to eq user_specified_network
        end
      end
    end
  end

  describe '#default_name' do
    let(:login) { 'user' }
    let(:hostname) { 'host' }

    before(:each) do
      allow(Etc).to receive(:getlogin).and_return(login)
      allow(Socket).to receive(:gethostname).and_return(hostname)
    end

    it 'generates a name' do
      expect(driver.send(:default_name)).to match(/^potatoes-user-host-(\S*)/)
    end

    context 'local node with a long hostname' do
      let(:hostname) { 'ab.c' * 20 }

      it 'limits the generated name to 63 characters' do
        expect(driver.send(:default_name).length).to be <= (63)
      end
    end

    context 'node with a long hostname, username, and base name' do
      let(:login) { 'abcd' * 20 }
      let(:hostname) { 'efgh' * 20 }
      let(:instance_name) { 'ijkl' * 20 }

      it 'limits the generated name to 63 characters' do
        expect(driver.send(:default_name).length).to eq(63)
      end
    end

    context 'a login and hostname with punctuation in them' do
      let(:login) { 'some.u-se-r' }
      let(:hostname) { 'a.host-name' }
      let(:instance_name) { 'a.instance-name' }

      it 'strips out the dots to prevent bad server names' do
        expect(driver.send(:default_name)).to_not include('.')
      end

      it 'strips out all but the three hyphen separators' do
        expect(driver.send(:default_name).count('-')).to eq(3)
      end
    end

    context 'a non-login shell' do
      let(:login) { nil }

      it 'subs in a placeholder login string' do
        expect(driver.send(:default_name)).to match(/^potatoes-nologin-/)
      end
    end
  end

  describe '#tcp_check' do
    before(:each) do
      allow_any_instance_of(described_class).to receive(:wait_for_sshd)
      allow_any_instance_of(described_class).to receive(:sleep)
    end

    context 'the default non-skipping behavior' do
      it "uses Kitchen's own SSH check" do
        expect(driver).to receive(:wait_for_sshd)
        expect(driver).to_not receive(:sleep)
        driver.send(:tcp_check, state)
      end
    end

    context 'a config set to wait instead of TCP check' do
      let(:config) { { no_ssh_tcp_check: true } }

      it 'uses a sleep instead of a port check' do
        expect(driver).to_not receive(:wait_for_sshd)
        expect(driver).to receive(:sleep)
        driver.send(:tcp_check, state)
      end
    end
  end

  describe '#networks' do
    context 'the default Rackspace networks' do
      it 'returns nil so Fog will use the defaults' do
        expect(driver.send(:networks)).to eq(nil)
      end
    end

    context 'a custom Rackspace network' do
      let(:config) { { networks: %w(abcdefg) } }

      it 'returns the base networks plus the custom one' do
        expected = %w(
          00000000-0000-0000-0000-000000000000
          11111111-1111-1111-1111-111111111111
          abcdefg
        )
        expect(driver.send(:networks)).to eq(expected)
      end
    end
  end
end
