require "rake"
require "rspec"
require "logger"
require "stringio" unless defined?(StringIO)
require "kitchen"

require_relative "../lib/kitchen/driver/rackspace"
RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run(:focus)
  config.order = "random"
end
