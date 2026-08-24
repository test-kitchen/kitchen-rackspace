#!/usr/bin/env ruby
# frozen_string_literal: true

# Regenerates data/images.json from the images a Rackspace account can see.
#
# The driver maps a Test Kitchen platform name (`ubuntu-22.04`) to a Rackspace
# image ID. That mapping lives in data/images.json and has to be refreshed
# whenever Rackspace publishes new base images.
#
# Usage:
#
#   export RACKSPACE_USERNAME=myuser
#   export RACKSPACE_API_KEY=myapikey
#   export RACKSPACE_REGION=ord            # optional, defaults to dfw
#
#   bundle exec ruby helpers/dump_image_list.rb          # human-readable table
#   bundle exec ruby helpers/dump_image_list.rb --json   # data/images.json content
#
# Run it under Bundler. fog-rackspace only loads against the fog-core version
# this gem pins; on a newer fog-core, `require "fog/rackspace"` raises NameError
# on its "CDN v2" service name.
#
# Image IDs are per-region, so regenerate from the region most users build in.

require "fog/rackspace"
require "json" unless defined?(JSON)

# Rackspace reports the distro in OpenStack metadata using reverse-DNS names.
# Map the ones that do not reduce to a sensible short name on their own.
DISTRO_NAMES = {
  "com.microsoft.server" => "windows",
  "org.archlinux" => "arch",
  "org.fedoraproject" => "fedora",
  "org.scientificlinux" => "scientific",
}.freeze

# Builds the platform aliases for one image.
#
# An image advertising Ubuntu 22.04 yields "ubuntu-22.04", plus "ubuntu-22" as
# a convenience. The bare distro name ("ubuntu") is assigned separately, to the
# newest version found, so that it does not depend on iteration order.
#
# @param image [Fog::Compute::RackspaceV2::Image] the image to describe
# @return [Array(String, String, Array<String>), nil] distro, version, and
#   aliases, or nil when the image carries no usable OpenStack metadata
def describe(image)
  meta = image.metadata
  distro_id = meta["org.openstack__1__os_distro"]
  version = meta["org.openstack__1__os_version"]
  return nil if distro_id.nil? || version.nil?

  distro = DISTRO_NAMES.fetch(distro_id) { distro_id.split(".").last }

  aliases = ["#{distro}-#{version}"]
  # "ubuntu-22" alongside "ubuntu-22.04", but not "centos-7" twice.
  major = version.split(".").first
  aliases << "#{distro}-#{major}" if major != version

  [distro, version, aliases]
end

# Sorts version strings numerically, so that 22.04 beats 8 and 9 beats 10 is
# never asserted. Non-numeric segments (Vyatta's "6.7R12") sort last.
#
# @param version [String] an OS version
# @return [Array<Integer>] a comparable key
def version_key(version)
  version.split(".").map { |part| part.to_i }
end

compute = Fog::Compute.new(
  provider: "Rackspace",
  rackspace_username: ENV.fetch("RACKSPACE_USERNAME"),
  rackspace_api_key: ENV.fetch("RACKSPACE_API_KEY"),
  rackspace_region: ENV.fetch("RACKSPACE_REGION", "dfw"),
  version: :v2
)

images = compute.images.to_a
abort "No images visible to this account." if images.empty?

if ARGV.include?("--json")
  mapping = {}
  newest = {}

  images.each do |image|
    described = describe(image)
    next if described.nil?

    distro, version, aliases = described
    aliases.each { |a| mapping[a] = image.id }

    current = newest[distro]
    if current.nil? || (version_key(version) <=> version_key(current[:version])) == 1
      newest[distro] = { version:, id: image.id }
    end
  end

  # The bare distro name points at the newest version of that distro.
  newest.each { |distro, info| mapping[distro] = info[:id] }

  puts JSON.pretty_generate(mapping.sort.to_h)
else
  rows = images.map do |image|
    described = describe(image)
    [image.id, image.name, described ? described[2].join(", ") : "-"]
  end.sort_by { |row| row[1] }

  widths = [0, 1, 2].map { |i| rows.map { |r| r[i].length }.max }
  header = ["IMAGE ID", "NAME", "PLATFORM NAMES"]
  widths = widths.each_with_index.map { |w, i| [w, header[i].length].max }

  puts header.each_with_index.map { |h, i| h.ljust(widths[i]) }.join("  ")
  puts widths.map { |w| "-" * w }.join("  ")
  rows.each { |row| puts row.each_with_index.map { |c, i| c.ljust(widths[i]) }.join("  ") }
  warn "\n#{rows.count} images. Re-run with --json to regenerate data/images.json."
end
