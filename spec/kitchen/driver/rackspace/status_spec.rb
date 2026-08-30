RSpec.describe Kitchen::Driver::Rackspace do
  include_context "a driver for an instance"

  describe "#status" do
    let(:server) { double("server", state: "ACTIVE") }
    let(:servers) { instance_double(Fog::Compute::RackspaceV2::Servers) }

    before do
      allow_any_instance_of(described_class).to receive(:compute)
        .and_return(double("compute", servers:))
    end

    context "with no server in state" do
      it "reports an unknown status" do
        expect(driver.status({})).to include(live: nil, state: "unknown")
      end
    end

    context "with a server Rackspace does not know" do
      it "reports an unknown status" do
        expect(servers).to receive(:get).with("gone").and_return(nil)

        expect(driver.status(server_id: "gone")).to include(state: "unknown")
      end
    end

    context "with a live server" do
      before do
        allow(servers).to receive(:get).with("12345").and_return(server)
      end

      it "reports the server as live" do
        expect(driver.status(server_id: "12345")).to include(
          live: true,
          state: "ACTIVE",
          source: "driver",
          resource_id: "12345"
        )
      end

      it "stamps when the check happened" do
        expect(driver.status(server_id: "12345")[:checked_at])
          .to match(/\A\d{4}-\d{2}-\d{2}T/)
      end
    end

    context "with a server that is not active" do
      it "reports the server as not live" do
        allow(servers).to receive(:get)
          .with("12345").and_return(double("server", state: "ERROR"))

        expect(driver.status(server_id: "12345"))
          .to include(live: false, state: "ERROR")
      end
    end

    context "when Rackspace cannot be reached" do
      it "reports an unknown status rather than raising" do
        allow(servers).to receive(:get)
          .and_raise(Fog::Errors::Error.new("boom"))

        expect(driver.status(server_id: "12345")).to include(state: "unknown")
      end

      it "survives an Excon error too" do
        allow(servers).to receive(:get)
          .and_raise(Excon::Errors::SocketError.new(StandardError.new("nope")))

        expect(driver.status(server_id: "12345")).to include(state: "unknown")
      end
    end
  end

  describe "#doctor" do
    let(:config) do
      { image_id: "img-1", public_key_path: "/home/user/.ssh/id_rsa.pub" }
    end
    let(:servers) do
      instance_double(Fog::Compute::RackspaceV2::Servers, all: [])
    end

    before do
      allow(driver).to receive(:compute)
        .and_return(double("compute", servers:))
    end

    it "reports no problem when the configuration is complete" do
      expect(driver.doctor(state)).to eq(false)
    end

    # `summary` is not a method fog-rackspace has. Stubbing the collection with
    # a verifying double is what keeps that mistake from coming back.
    it "asks Rackspace for something fog actually implements" do
      driver.doctor(state)

      expect(servers).to have_received(:all)
    end

    context "with no resolvable image" do
      let(:config) { { public_key_path: "/key.pub" } }

      it "reports a problem" do
        allow(driver).to receive(:default_image).and_return(nil)

        expect(driver.doctor(state)).to eq(true)
        expect(logged_output.string).to match(/No image_id is set/)
      end
    end

    context "with no public key" do
      let(:config) { { image_id: "img-1", public_key_path: nil } }

      it "reports a problem" do
        expect(driver.doctor(state)).to eq(true)
        expect(logged_output.string).to match(/No public key was found/)
      end
    end

    context "with credentials Rackspace rejects" do
      it "reports a problem" do
        allow(driver).to receive(:compute)
          .and_raise(Fog::Errors::Error.new("unauthorized"))

        expect(driver.doctor(state)).to eq(true)
        expect(logged_output.string)
          .to match(/rejected the configured credentials/)
      end

      it "names the region it tried" do
        config[:rackspace_region] = "ord"
        allow(driver).to receive(:compute)
          .and_raise(Fog::Errors::Error.new("unauthorized"))

        driver.doctor(state)

        expect(logged_output.string).to match(/region ord/)
      end
    end

    it "reports every problem it finds, not just the first" do
      config.delete(:image_id)
      config[:public_key_path] = nil
      allow(driver).to receive(:default_image).and_return(nil)

      driver.doctor(state)

      expect(logged_output.string).to match(/No image_id is set/)
      expect(logged_output.string).to match(/No public key was found/)
    end
  end
end
