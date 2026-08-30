require "rake"
require "rspec"
require "logger"
require "stringio" unless defined?(StringIO)
require "kitchen"

require_relative "../lib/kitchen/driver/rackspace"

# `require "fog/rackspace"` only registers the services; it does not load the
# model classes. Load the ones the specs verify doubles against, so that a
# stubbed method which fog does not actually implement fails the example
# instead of quietly passing.
require "fog/rackspace/models/compute_v2/servers"
RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run(:focus)
  config.order = "random"
end
