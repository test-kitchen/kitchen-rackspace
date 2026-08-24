#!/usr/bin/env ruby
# frozen_string_literal: true

# Lists the flavors a Rackspace account can build, for setting `flavor_id`.
#
# Flavor availability varies by account and region, and Rackspace retires
# flavor classes over time, so this is the authoritative answer for a given
# account rather than the tables in the README.
#
# Usage:
#
#   export RACKSPACE_USERNAME=myuser
#   export RACKSPACE_API_KEY=myapikey
#   export RACKSPACE_REGION=ord            # optional, defaults to dfw
#
#   bundle exec ruby helpers/dump_flavor_list.rb
#
# Run it under Bundler. fog-rackspace only loads against the fog-core version
# this gem pins; on a newer fog-core, `require "fog/rackspace"` raises NameError
# on its "CDN v2" service name.

require "fog/rackspace"

compute = Fog::Compute.new(
  provider: "Rackspace",
  rackspace_username: ENV.fetch("RACKSPACE_USERNAME"),
  rackspace_api_key: ENV.fetch("RACKSPACE_API_KEY"),
  rackspace_region: ENV.fetch("RACKSPACE_REGION", "dfw"),
  version: :v2
)

flavors = compute.flavors.to_a
abort "No flavors visible to this account." if flavors.empty?

rows = flavors
  .sort_by { |f| [f.ram.to_i, f.id.to_s] }
  .map { |f| [f.id.to_s, "#{f.ram} MB", "#{f.vcpus} vCPU", "#{f.disk} GB"] }

header = %w{FLAVOR RAM VCPUS DISK}
widths = header.each_index.map do |i|
  ([header[i]] + rows.map { |r| r[i] }).map(&:length).max
end

puts header.each_with_index.map { |h, i| h.ljust(widths[i]) }.join("  ")
puts widths.map { |w| "-" * w }.join("  ")
rows.each { |row| puts row.each_with_index.map { |c, i| c.ljust(widths[i]) }.join("  ") }
