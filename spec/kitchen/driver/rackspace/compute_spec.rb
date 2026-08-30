RSpec.describe Kitchen::Driver::Rackspace do
  include_context "a driver for an instance"

  describe "#compute" do
    let(:config) do
      {
        rackspace_username: "monkey",
        rackspace_api_key: "potato",
        rackspace_region: "ord",
      }
    end

    context "all requirements provided" do
      it "creates a new compute connection" do
        allow(Fog::Compute).to receive(:new) { |arg| arg }

        expect(driver.send(:compute)).to eq(
          provider: "Rackspace",
          version: "v2",
          rackspace_username: "monkey",
          rackspace_api_key: "potato",
          rackspace_region: "ord"
        )
      end
    end

    context "no username provided" do
      let(:config) { { rackspace_username: nil, rackspace_api_key: "1234" } }

      it "raises an error" do
        expect { driver.send(:compute) }.to raise_error(ArgumentError)
      end
    end

    context "no API key provided" do
      let(:config) { { rackspace_username: "monkey", rackspace_api_key: nil } }

      it "raises an error" do
        expect { driver.send(:compute) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#create_server" do
    subject(:server_def) { driver.send(:create_server) }

    let(:config) do
      {
        server_name: "hello",
        image_id: "there",
        flavor_id: "captain",
        public_key_path: "tarpals",
        no_passwd_lock: false,
        networks: nil,
        user_data: nil,
        config_drive: false,
      }
    end
    let(:servers) do
      collection = instance_double(Fog::Compute::RackspaceV2::Servers)
      allow(collection).to receive(:bootstrap) { |arg| arg }
      collection
    end

    before do
      allow_any_instance_of(described_class).to receive(:compute)
        .and_return(double("compute", servers:))
    end

    it "creates the server using a compute connection" do
      expect(server_def).to eq(
        name: "hello",
        image_id: "there",
        flavor_id: "captain",
        public_key_path: "tarpals",
        no_passwd_lock: false,
        networks: nil,
        user_data: nil,
        config_drive: false
      )
    end

    it "passes user data through" do
      config[:user_data] = "#cloud-config\n"

      expect(server_def[:user_data]).to eq("#cloud-config\n")
    end

    it "passes the config drive setting through" do
      config[:config_drive] = true

      expect(server_def[:config_drive]).to eq(true)
    end

    # RackConnect and Managed Service Level both need to log in as root to do
    # their work, so the driver overrides no_passwd_lock whenever either wait
    # is requested. Getting this wrong leaves the automation stuck forever.
    context "rackconnect_wait is set" do
      before { config[:rackconnect_wait] = true }

      it "unlocks the root password even though the option says otherwise" do
        expect(server_def[:no_passwd_lock]).to eq(true)
      end
    end

    context "servicelevel_wait is set" do
      before { config[:servicelevel_wait] = true }

      it "unlocks the root password even though the option says otherwise" do
        expect(server_def[:no_passwd_lock]).to eq(true)
      end
    end

    context "neither wait is set" do
      it "leaves the configured no_passwd_lock alone" do
        config[:no_passwd_lock] = true

        expect(server_def[:no_passwd_lock]).to eq(true)
      end

      it "leaves a false no_passwd_lock alone" do
        expect(server_def[:no_passwd_lock]).to eq(false)
      end
    end

    context "additional networks specified" do
      before { config[:networks] = %w{bob_dole} }

      it "keeps PublicNet and ServiceNet ahead of the custom network" do
        expect(server_def[:networks]).to eq(
          %w{
            00000000-0000-0000-0000-000000000000
            11111111-1111-1111-1111-111111111111
            bob_dole
          }
        )
      end
    end
  end

  describe "#networks" do
    context "the default Rackspace networks" do
      it "returns nil so Fog will use the defaults" do
        expect(driver.send(:networks)).to be_nil
      end
    end

    context "a custom Rackspace network" do
      let(:config) { { networks: %w{abcdefg} } }

      it "returns the base networks plus the custom one" do
        expect(driver.send(:networks)).to eq(
          %w{
            00000000-0000-0000-0000-000000000000
            11111111-1111-1111-1111-111111111111
            abcdefg
          }
        )
      end
    end
  end
end
