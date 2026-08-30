# Everything a driver needs to exist outside a real Test Kitchen run: an
# instance to belong to, a logger to talk to, and a config hash to read.
#
# Individual example groups override `config`, `platform_name`, and
# `instance_name` with `let` to describe the situation under test.
RSpec.shared_context "a driver for an instance" do
  let(:logged_output) { StringIO.new }
  let(:logger) { Logger.new(logged_output) }
  let(:config) { {} }
  let(:state) { {} }
  let(:platform_name) { "ubuntu" }
  let(:instance_name) { "potatoes" }

  let(:instance) do
    double("instance",
           name: instance_name,
           logger:,
           to_str: "instance",
           platform: double("platform", name: platform_name))
  end

  let(:driver) { described_class.new(config) }

  before do
    allow_any_instance_of(described_class).to receive(:instance)
      .and_return(instance)
    ENV["RACKSPACE_USERNAME"] = "user"
    ENV["RACKSPACE_API_KEY"] = "key"
  end
end

# A server that has finished building and is reachable, as `#create` sees it.
RSpec.shared_context "a built server" do
  let(:server) do
    double("server",
           id: "test123",
           wait_for: true,
           update: nil,
           public_ip_address: "1.2.3.4",
           private_ip_address: "10.9.8.7")
  end

  before do
    allow_any_instance_of(described_class).to receive(:default_name)
      .and_return("a_monkey!")
    allow_any_instance_of(described_class).to receive(:create_server)
      .and_return(server)
    allow_any_instance_of(described_class).to receive(:tcp_check)
      .and_return(true)
  end
end
