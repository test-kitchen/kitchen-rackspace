RSpec.describe Kitchen::Driver::Rackspace do
  include_context "a driver for an instance"

  describe "#default_name" do
    subject(:name) { driver.default_name }

    let(:login) { "user" }
    let(:hostname) { "host" }

    before do
      allow(Etc).to receive(:getlogin).and_return(login)
      allow(Socket).to receive(:gethostname).and_return(hostname)
    end

    it "generates a name" do
      expect(name).to match(/^potatoes-user-host-(\S*)/)
    end

    context "a local node with a long hostname" do
      let(:hostname) { "ab.c" * 20 }

      it "limits the generated name to 63 characters" do
        expect(name.length).to be <= 63
      end
    end

    context "a long hostname, username, and base name" do
      let(:login) { "abcd" * 20 }
      let(:hostname) { "efgh" * 20 }
      let(:instance_name) { "ijkl" * 20 }

      it "limits the generated name to 63 characters" do
        expect(name.length).to eq(63)
      end
    end

    context "a login and hostname with punctuation in them" do
      let(:login) { "some.u-se-r" }
      let(:hostname) { "a.host-name" }
      let(:instance_name) { "a.instance-name" }

      it "strips out the dots to prevent bad server names" do
        expect(name).to_not include(".")
      end

      it "strips out all but the three hyphen separators" do
        expect(name.count("-")).to eq(3)
      end
    end

    context "a non-login shell" do
      let(:login) { nil }

      it "subs in a placeholder login string" do
        expect(name).to match(/^potatoes-nologin-/)
      end
    end

    it "does not repeat itself" do
      expect(driver.default_name).to_not eq(driver.default_name)
    end
  end
end
