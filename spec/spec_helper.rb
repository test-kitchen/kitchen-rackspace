require "logger"
require "stringio" unless defined?(StringIO)
require "kitchen"

require_relative "../lib/kitchen/driver/rackspace"

# `require "fog/rackspace"` only registers the services; it does not load the
# model classes. Load the ones the specs verify doubles against, so that a
# stubbed method which fog does not actually implement fails the example
# instead of quietly passing.
require "fog/rackspace/models/compute_v2/servers"

Dir[File.expand_path("support/**/*.rb", __dir__)].sort.each { |f| require f }

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.filter_run_when_matching :focus
  config.order = :random
  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end
