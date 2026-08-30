RSpec.describe Kitchen::Driver::Rackspace do
  include_context "a driver for an instance"

  describe "#destroy" do
    let(:server) { double("server", nil?: false, destroy: true) }
    let(:servers) { instance_double(Fog::Compute::RackspaceV2::Servers, get: server) }
    let(:state) { { server_id: "12345", hostname: "example.com" } }

    before do
      allow_any_instance_of(described_class).to receive(:compute)
        .and_return(double("compute", servers:))
    end

    context "a live server that needs to be destroyed" do
      it "destroys the server" do
        expect(server).to receive(:destroy)

        driver.destroy(state)
      end

      it "clears the server out of the state" do
        driver.destroy(state)

        expect(state).to_not include(:server_id)
        expect(state).to_not include(:hostname)
      end

      it "says which server it destroyed" do
        driver.destroy(state)

        expect(logged_output.string).to match(/instance <12345> destroyed/)
      end
    end

    context "no server ID present" do
      let(:state) { {} }

      it "does nothing" do
        expect(driver).to_not receive(:compute)

        expect { driver.destroy(state) }.to_not raise_error
      end
    end

    context "a server that was already destroyed" do
      let(:servers) do
        instance_double(Fog::Compute::RackspaceV2::Servers, get: nil)
      end

      it "does not try to destroy the server again" do
        expect(server).to_not receive(:destroy)

        driver.destroy(state)
      end

      it "still clears the server out of the state" do
        driver.destroy(state)

        expect(state).to_not include(:server_id)
      end
    end
  end
end
