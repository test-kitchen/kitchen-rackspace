RSpec.describe Kitchen::Driver::Rackspace do
  include_context "a driver for an instance"

  describe "#tcp_check" do
    before do
      allow_any_instance_of(described_class).to receive(:wait_for_sshd)
      allow_any_instance_of(described_class).to receive(:sleep)
    end

    context "the default non-skipping behavior" do
      it "uses Kitchen's own SSH check" do
        expect(driver).to receive(:wait_for_sshd).with(state)
        expect(driver).to_not receive(:sleep)

        driver.send(:tcp_check, state)
      end
    end

    context "a config set to wait instead of TCP check" do
      let(:config) { { no_ssh_tcp_check: true } }

      it "uses a sleep instead of a port check" do
        expect(driver).to_not receive(:wait_for_sshd)
        expect(driver).to receive(:sleep)

        driver.send(:tcp_check, state)
      end

      it "sleeps for the configured number of seconds" do
        config[:no_ssh_tcp_check_sleep] = 42
        expect(driver).to receive(:sleep).with(42)

        driver.send(:tcp_check, state)
      end
    end
  end
end
