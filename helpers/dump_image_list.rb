#!/usr/bin/env ruby
# Encoding: UTF-8

require 'fog'
require 'json'

i_care_about = {
  'Arch 2015.3 (PVHVM)' => %w(arch arch-2015 arch-2015.3),
  'CentOS 7 (PVHVM)' => %w(centos centos-7),
  'CentOS 6 (PVHVM)' => %w(centos-6),
  'CentOS 5 (PV)' => %w(centos-5),
  'CoreOS (Stable)' => %w(coreos coreos-stable),
  'CoreOS (Beta)' => %w(coreos-beta),
  'CoreOS (Alpha)' => %w(coreos-alpha),
  'Debian 7 (Wheezy) (PVHVM)' => %w(debian debian-7),
  'Debian 6 (Squeeze) (PV)' => %w(debian-6),
  'Debian Testing (Jessie) (PVHVM)' => %w(debian-testing),
  'Debian Unstable (Sid) (PVHVM)' => %w(debian-unstable),
  'Fedora 21 (PVHVM)' => %w(fedora fedora-21),
  'Fedora 20 (Heisenbug) (PVHVM)' => %w(fedora-20),
  'FreeBSD 10 (PVHVM)' => %w(freebsd freebsd-10),
  'Gentoo 15.1 (PVHVM)' => %w(gentoo gentoo-15 gentoo-15.1),
  'OpenSUSE 13.2 (PVHVM)' => %w(opensuse opensuse-13 opensuse-13.2),
  'Red Hat Enterprise Linux 7 (PVHVM)' => %w(redhat redhat-7),
  'Red Hat Enterprise Linux 6 (PVHVM)' => %w(redhat-6),
  'Red Hat Enterprise Linux 5 (PV)' => %w(redhat-5),
  'Scientific Linux 7 (PVHVM)' => %w(scientific scientific-7),
  'Scientific Linux 6 (PVHVM)' => %w(scientific-6),
  'Ubuntu 14.10 (Utopic Unicorn) (PVHVM)' => %w(ubuntu ubuntu-14 ubuntu-14.10),
  'Ubuntu 14.04 LTS (Trusty Tahr) (PVHVM)' => %w(ubuntu-14.04),
  'Ubuntu 12.04 LTS (Precise Pangolin) (PVHVM)' => %w(ubuntu-12 ubuntu-12.04),
  'Ubuntu 10.04 LTS (Lucid Lynx) (PV)' => %w(ubuntu-10 ubuntu-10.04),
  'Vyatta Network OS 6.7R6' => %w(vyatta vyatta-6 vyatta-6.7 vyatta-6.7R6),
  'Windows Server 2012 R2' => %w(windows windows-2012 windows-2012R2),
  'Windows Server 2008 R2 SP1' => %w(windows-2008
                                     windows-2008R2
                                     windows-2008R2SP1)
}

compute = Fog::Compute.new(provider: 'Rackspace',
                           rackspace_username: ENV['RACKSPACE_USERNAME'],
                           rackspace_api_key: ENV['RACKSPACE_API_KEY'],
                           rackspace_region: 'ORD')

aliases = i_care_about.values.flatten
res = aliases.each_with_object({}) do |a, hsh|
  fail "Alias '#{a}' was listed twice" if hsh.include?(a)
  hsh.merge!(a => nil)
  hsh
end

compute.images.select { |i| i_care_about.keys.include?(i.name) }.each do |img|
  i_care_about[img.name].each { |a| res[a] = img.id }
  i_care_about.delete(img.name)
end

unless i_care_about.empty?
  fail "Couldn't find some images we expected: #{i_care_about.keys}"
end

puts JSON.pretty_generate(res)
