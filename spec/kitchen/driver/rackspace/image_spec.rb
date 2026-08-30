RSpec.describe Kitchen::Driver::Rackspace do
  include_context "a driver for an instance"

  describe "#default_image" do
    {
      "ubuntu-12.04" => "f2d30a56-bc2b-4906-8027-92f8a45bbb10",
      "ubuntu-12" => "f2d30a56-bc2b-4906-8027-92f8a45bbb10",
      "ubuntu-14.04" => "e6baca58-c5f4-48d3-901a-abdeb0cfe907",
      "ubuntu-14" => "e6baca58-c5f4-48d3-901a-abdeb0cfe907",
      "ubuntu" => "9b3ae961-0ba0-4d5a-973f-2e79043f0ddd",
      "centos-6" => "7d791876-4c8f-44a2-8d4b-e84bfb0b1c8c",
      "centos" => "1a79f262-33d2-428c-924b-9852a6c15ea8",
    }.each do |platform, id|
      context "the platform is #{platform}" do
        let(:platform_name) { platform }

        it "resolves it to the right image ID" do
          expect(driver[:image_id]).to eq(id)
        end
      end
    end

    # The bundled table has not been regenerated since 2016, so every modern
    # platform name lands here. `image_id` then has no value, `required_config`
    # rejects it, and the user has to supply one -- which is exactly what the
    # README tells them to do. If this ever starts returning something, the
    # README is wrong.
    context "a platform the bundled table does not know" do
      let(:platform_name) { "ubuntu-24.04" }

      it "has no image to offer" do
        expect(driver.default_image).to be_nil
      end
    end
  end

  describe "the bundled image table" do
    subject(:images) { driver.send(:images) }

    it "parses as JSON" do
      expect { images }.to_not raise_error
    end

    it "is not empty" do
      expect(images).to_not be_empty
    end

    it "maps every platform name to a UUID" do
      expect(images.values).to all(match(/\A\h{8}(-\h{4}){3}-\h{12}\z/))
    end

    it "is only read from disk once" do
      expect(IO).to receive(:read).once.and_call_original

      2.times { driver.send(:images) }
    end
  end
end
