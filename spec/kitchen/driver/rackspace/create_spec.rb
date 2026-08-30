RSpec.describe Kitchen::Driver::Rackspace do
  include_context "a driver for an instance"
  include_context "a built server"

  let(:credentials) do
    { rackspace_username: "hello", rackspace_api_key: "world", wait_for: 1200 }
  end
  let(:config) { credentials }

  describe "#create" do
    it "generates a server name in the absence of one" do
      driver.create(state)

      expect(driver[:server_name]).to eq("a_monkey!")
    end

    it "records the server ID" do
      driver.create(state)

      expect(state[:server_id]).to eq("test123")
    end

    it "records the public IP as the hostname" do
      driver.create(state)

      expect(state[:hostname]).to eq("1.2.3.4")
    end

    it "records the login user" do
      driver.create(state)

      expect(state[:username]).to eq("root")
    end

    it "records the SSH port" do
      driver.create(state)

      expect(state[:port]).to eq("22")
    end

    it "records an overridden login user and port" do
      config.merge!(username: "admin", port: "2222")
      driver.create(state)

      expect(state).to include(username: "admin", port: "2222")
    end

    it "waits for the server to report ready" do
      expect(server).to receive(:wait_for)

      driver.create(state)
    end

    it "waits for the instance to accept a login" do
      expect(driver).to receive(:tcp_check).with(state)

      driver.create(state)
    end

    it "does not wait for rackconnect by default" do
      expect(driver).to_not receive(:rackconnect_check)

      driver.create(state)
    end

    it "does not wait for managed service level by default" do
      expect(driver).to_not receive(:servicelevel_check)

      driver.create(state)
    end

    context "a Fog error" do
      before do
        allow_any_instance_of(described_class).to receive(:create_server)
          .and_raise(Fog::Errors::Error, "Uhoh")
      end

      it "re-raises it as a Kitchen failure" do
        expect { driver.create(state) }
          .to raise_error(Kitchen::ActionFailed, "Uhoh")
      end
    end

    # Anything the Rackspace API rejects surfaces from Excon rather than fog,
    # and it has to be turned into a Kitchen failure too or the user gets a
    # raw stack trace instead of a message.
    context "an Excon error" do
      before do
        allow_any_instance_of(described_class).to receive(:create_server)
          .and_raise(Excon::Errors::BadRequest, "Bad flavor")
      end

      it "re-raises it as a Kitchen failure" do
        expect { driver.create(state) }
          .to raise_error(Kitchen::ActionFailed, /Bad flavor/)
      end
    end
  end

  describe "#create with rackconnect_wait" do
    let(:config) { credentials.merge(rackconnect_wait: true) }

    it "waits for rackconnect" do
      expect(driver).to receive(:rackconnect_check).with(server)

      driver.create(state)
    end

    it "waits on the rackconnect automation status" do
      driver.send(:rackconnect_check, server)

      expect(server).to have_received(:wait_for)
    end

    # RackConnect hands the server a new public address as part of its work.
    # Without the refresh, the stale address goes into the state file and the
    # transport connects to nothing.
    it "refreshes the server so the new public IP is picked up" do
      driver.send(:rackconnect_check, server)

      expect(server).to have_received(:update)
    end
  end

  describe "#create with servicelevel_wait" do
    let(:config) { credentials.merge(servicelevel_wait: true) }

    it "waits for managed service level automation" do
      expect(driver).to receive(:servicelevel_check).with(server)

      driver.create(state)
    end

    it "waits on the service level automation status" do
      driver.send(:servicelevel_check, server)

      expect(server).to have_received(:wait_for)
    end
  end

  describe "#create with servicenet" do
    let(:config) { credentials.merge(servicenet: true) }

    it "records the private IP as the hostname" do
      driver.create(state)

      expect(state[:hostname]).to eq("10.9.8.7")
    end
  end
end
