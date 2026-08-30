RSpec.describe Kitchen::Driver::Rackspace do
  include_context "a driver for an instance"

  before do
    allow(Fog).to receive(:timeout=)
  end

  describe "default options" do
    it "defaults to v2 cloud" do
      expect(driver[:version]).to eq("v2")
    end

    it "defaults to a 2 GB general purpose flavor" do
      expect(driver[:flavor_id]).to eq("general1-2")
    end

    it "defaults to local user's SSH public key" do
      expect(File).to receive(:exist?).with(%r{/.ssh/id_rsa.pub$})
        .and_return(true)

      expect(driver[:public_key_path]).to match(%r{/.ssh/id_rsa.pub$})
    end

    it "falls through the other key types when there is no RSA key" do
      allow(File).to receive(:exist?).and_return(false)
      allow(File).to receive(:exist?).with(%r{/.ssh/id_ecdsa.pub$})
        .and_return(true)

      expect(driver[:public_key_path]).to match(%r{/.ssh/id_ecdsa.pub$})
    end

    it "leaves public_key_path unset when ~/.ssh holds no public key" do
      allow(File).to receive(:exist?).and_return(false)

      expect(driver[:public_key_path]).to be_nil
    end

    it "defaults to SSH with root user on port 22" do
      expect(driver[:username]).to eq("root")
      expect(driver[:port]).to eq("22")
    end

    it "defaults to a random server name" do
      expect(driver[:server_name]).to match(/^potatoes-/)
    end

    it "defaults to the DFW region" do
      expect(driver[:rackspace_region]).to eq("dfw")
    end

    it "defaults to username from $RACKSPACE_USERNAME" do
      expect(driver[:rackspace_username]).to eq("user")
    end

    it "defaults to API key from $RACKSPACE_API_KEY" do
      expect(driver[:rackspace_api_key]).to eq("key")
    end

    it "defaults to wait_for timeout of 600 seconds" do
      expect(driver[:wait_for]).to eq(600)
    end

    it "defaults the SSH TCP bypassing to false" do
      expect(driver[:no_ssh_tcp_check]).to eq(false)
    end

    it "defaults the TCP bypass sleep time to 120 seconds" do
      expect(driver[:no_ssh_tcp_check_sleep]).to eq(120)
    end

    it "defaults to the standard Rackspace networks" do
      expect(driver[:networks]).to eq(nil)
    end

    it "defaults to not waiting for rackconnect" do
      expect(driver[:rackconnect_wait]).to eq(false)
    end

    it "defaults to not waiting for managed service level" do
      expect(driver[:servicelevel_wait]).to eq(false)
    end

    it "defaults to the public ip address" do
      expect(driver[:servicenet]).to eq(false)
    end

    it "defaults to no_passwd_lock as false" do
      expect(driver[:no_passwd_lock]).to eq(false)
    end

    it "defaults to attaching the config drive" do
      expect(driver[:config_drive]).to eq(true)
    end

    it "defaults to sending no user data" do
      expect(driver[:user_data]).to eq(nil)
    end
  end

  describe "overridden options" do
    overrides = {
      version: "v3",
      image_id: "22",
      flavor_id: "33",
      public_key_path: "/tmp",
      username: "admin",
      port: "2222",
      server_name: "puppy",
      rackspace_region: "ord",
      wait_for: 1200,
      rackconnect_wait: true,
      servicelevel_wait: true,
      servicenet: true,
      no_passwd_lock: true,
      no_ssh_tcp_check: true,
      no_ssh_tcp_check_sleep: 180,
      config_drive: false,
      user_data: "#cloud-config\n",
      networks: %w{abcdefg},
    }
    let(:config) { overrides.dup }

    # Every key here is a real `default_config` on the driver. Asserting that
    # first keeps this list from drifting into options that do not exist --
    # `driver[:whatever]` happily echoes back anything you put in the config
    # hash, so a test for a made-up option passes without proving anything.
    it "only names options the driver actually declares" do
      expect(described_class.defaults.keys).to include(*overrides.keys)
    end

    overrides.each do |key, value|
      it "uses the overridden #{key} option" do
        expect(driver[key]).to eq(value)
      end
    end
  end

  describe "credentials from the environment" do
    it "reads the username from $RACKSPACE_USERNAME" do
      ENV["RACKSPACE_USERNAME"] = "rax_user"

      expect(driver[:rackspace_username]).to eq("rax_user")
    end

    it "falls back to $OS_USERNAME" do
      ENV.delete("RACKSPACE_USERNAME")
      ENV["OS_USERNAME"] = "os_user"

      expect(driver[:rackspace_username]).to eq("os_user")
    end

    it "prefers $RACKSPACE_USERNAME over $OS_USERNAME" do
      ENV["RACKSPACE_USERNAME"] = "rax_user"
      ENV["OS_USERNAME"] = "os_user"

      expect(driver[:rackspace_username]).to eq("rax_user")
    end

    it "falls back to $OS_PASSWORD for the API key" do
      ENV.delete("RACKSPACE_API_KEY")
      ENV["OS_PASSWORD"] = "os_pass"

      expect(driver[:rackspace_api_key]).to eq("os_pass")
    end

    it "prefers $RACKSPACE_API_KEY over $OS_PASSWORD" do
      ENV["RACKSPACE_API_KEY"] = "rax_key"
      ENV["OS_PASSWORD"] = "os_pass"

      expect(driver[:rackspace_api_key]).to eq("rax_key")
    end

    it "falls back to $OS_REGION_NAME for the region" do
      ENV["OS_REGION_NAME"] = "os_region"

      expect(driver[:rackspace_region]).to eq("os_region")
    end

    it "prefers $RACKSPACE_REGION over $OS_REGION_NAME" do
      ENV["RACKSPACE_REGION"] = "ord"
      ENV["OS_REGION_NAME"] = "os_region"

      expect(driver[:rackspace_region]).to eq("ord")
    end

    it "falls back to dfw when neither region variable is set" do
      expect(driver[:rackspace_region]).to eq("dfw")
    end
  end

  describe "the fog timeout" do
    it "hands wait_for to fog as its global timeout" do
      described_class.new(wait_for: 1200)

      expect(Fog).to have_received(:timeout=).with(1200)
    end

    it "uses the wait_for default when the option is not set" do
      described_class.new({})

      expect(Fog).to have_received(:timeout=).with(600)
    end

    it "coerces a wait_for given as a string" do
      described_class.new(wait_for: "1200")

      expect(Fog).to have_received(:timeout=).with(1200)
    end
  end
end
