RSpec.describe Kitchen::Driver::Rackspace do
  include_context "a driver for an instance"

  describe "plugin metadata" do
    it "declares the driver API version" do
      expect(described_class.instance_variable_get(:@api_version)).to eq(2)
    end

    it "reports its own gem version to kitchen diagnose" do
      expect(driver.diagnose_plugin[:version])
        .to eq(Kitchen::Driver::RACKSPACE_VERSION)
    end
  end
end
