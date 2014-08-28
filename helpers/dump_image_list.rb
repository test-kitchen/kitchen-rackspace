#!/usr/bin/env ruby

require 'fog'
require 'json'

i_care_about = {
  'Arch 2014.8 (PVHVM)' => %w(arch arch-2014 arch-2014.8),
  'CentOS 7 (PVHVM)' => %w(centos centos-7 centos-7.0),
  'CentOS 6.5 (PVHVM)' => %w(centos-6 centos-6.5),
  'CentOS 5.10' => %w(centos-5 centos-5.10),
  'CoreOS (Stable)' => %w(coreos coreos-stable),
  'CoreOS (Beta)' => %w(coreos-beta),
  'CoreOS (Alpha)' => %w(coreos-alpha),
  'Debian 7 (Wheezy) (PVHVM)' => %w(debian debian-7 debian-7.6),
  'Debian 6.06 (Squeeze)' => %w(debian-6 debian-6.06),
  'Debian Testing (Jessie) (PVHVM)' => %w(debian-testing),
  'Debian Unstable (Sid) (PVHVM)' => %w(debian-unstable),
  'Fedora 20 (Heisenbug) (PVHVM)' => %w(fedora fedora-20),
  "Fedora 19 (Schrodinger's Cat) (PVHVM)" => %w(fedora-19),
  'FreeBSD 10.0' => %w(freebsd freebsd-10 freebsd-10.0),
  'Gentoo 14.3 (PVHVM)' => %w(gentoo gentoo-14 gentoo-14.3),
  'OpenSUSE 13.1 (PVHVM)' => %w(opensuse opensuse-13 opensuse-13.1),
  'Red Hat Enterprise Linux 6.5 (PVHVM)' => %w(redhat redhat-6 redhat-6.5),
  'Red Hat Enterprise Linux 5.10' => %w(redhat-5 redhat-5.10),
  'Scientific Linux 6.5 (PVHVM)' => %w(scientific scientific-6 scientific-6.5),
  'Ubuntu 14.04 LTS (Trusty Tahr) (PVHVM)' => %w(ubuntu ubuntu-14 ubuntu-14.04),
  'Ubuntu 12.04 LTS (Precise Pangolin) (PVHVM)' => %w(ubuntu-12 ubuntu-12.04),
  'Ubuntu 10.04 LTS (Lucid Lynx)' => %w(ubuntu-10 ubuntu-10.04),
  'Vyatta Network OS 6.5R2' => %w(vyatta vyatta-6 vyatta-6.5 vyatta-6.5R2),
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
