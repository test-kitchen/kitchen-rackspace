#!/usr/bin/env ruby
# Encoding: UTF-8

require 'fog'
require 'json'

def whole?(x)
  (x - x.floor) < 1e-6
end

i_care_about = {
  'Arch 2015.7 (PVHVM)' => %w(arch arch-2015 arch-2015.7),
  'CentOS 7 (PVHVM)' => %w(centos centos-7),
  'CentOS 6 (PVHVM)' => %w(centos-6),
  'CentOS 5 (PV)' => %w(centos-5),
  'CoreOS (Stable)' => %w(coreos coreos-stable),
  'CoreOS (Beta)' => %w(coreos-beta),
  'CoreOS (Alpha)' => %w(coreos-alpha),
  'Debian 8 (Jessie) (PVHVM)' => %w(debian debian-8),
  'Debian 7 (Wheezy) (PVHVM)' => %w(debian-7),
  'Debian Testing (Stretch) (PVHVM)' => %w(debian-testing),
  'Debian Unstable (Sid) (PVHVM)' => %w(debian-unstable),
  'Fedora 21 (PVHVM)' => %w(fedora-21),
  'Fedora 22 (PVHVM)' => %w(fedora fedora-22),
  'FreeBSD 10 (PVHVM)' => %w(freebsd freebsd-10),
  'Gentoo 15.3 (PVHVM)' => %w(gentoo gentoo-15 gentoo-15.3),
  'OpenSUSE 13.2 (PVHVM)' => %w(opensuse opensuse-13 opensuse-13.2),
  'Red Hat Enterprise Linux 7 (PVHVM)' => %w(redhat redhat-7),
  'Red Hat Enterprise Linux 6 (PVHVM)' => %w(redhat-6),
  'Red Hat Enterprise Linux 5 (PV)' => %w(redhat-5),
  'Scientific Linux 7 (PVHVM)' => %w(scientific scientific-7),
  'Scientific Linux 6 (PVHVM)' => %w(scientific-6),
  'Ubuntu 15.10 (Wily Werewolf) (PVHVM)' => %w(ubuntu ubuntu-15 ubuntu-15.10),
  'Ubuntu 14.04 LTS (Trusty Tahr) (PVHVM)' => %w(ubuntu-14 ubuntu-14.04),
  'Ubuntu 12.04 LTS (Precise Pangolin) (PVHVM)' => %w(ubuntu-12 ubuntu-12.04),
  'Vyatta Network OS 6.7R9' => %w(vyatta vyatta-6 vyatta-6.7 vyatta-6.7R9),
  'Windows Server 2012 R2' => %w(windows windows-2012 windows-2012R2),
  'Windows Server 2008 R2 SP1' => %w(windows-2008
                                     windows-2008R2
                                     windows-2008R2SP1)
}

names_to_clean = {
  'com.microsoft.server' => 'windows',
  'org.fedoraproject' => 'fedora',
  'org.archlinux' => 'arch',
  'org.scientificlinux' => 'scientific'
}

compute = Fog::Compute.new(provider: 'Rackspace',
                           rackspace_username: ENV['RACKSPACE_USERNAME'],
                           rackspace_api_key: ENV['RACKSPACE_API_KEY'],
                           rackspace_region: 'ORD')

aliases = i_care_about.values.flatten
res = aliases.each_with_object({}) do |a, hsh|
  fail "Alias '#{a}' was listed twice" if hsh.include?(a)
  hsh[a] = nil
  hsh
end

compute.images.select { |i| i_care_about.keys.include?(i.name) }.each do |img|
  image_metadata = img.metadata

  if image_metadata['org.openstack__1__os_distro'] &&
     image_metadata['org.openstack__1__os_version']

    distro_id = image_metadata['org.openstack__1__os_distro']
    version = image_metadata['org.openstack__1__os_version']

    distro = if names_to_clean.include?(distro_id)
               names_to_clean[distro_id]
             else
               distro_id.split('.').last
             end

    res["#{distro}-#{version}"] = img.id

    # if it's a whole number non-zero version, also add
    # a dot-zero (centos-7 vs centos-7.0)
    if version != '0' && version =~ /^\s*\d+\s*$/
      res["#{distro}-#{version}.0"] = img.id
    end
  end

  i_care_about[img.name].each { |a| res[a] = img.id }
  i_care_about.delete(img.name)
end

unless i_care_about.empty?
  fail "Couldn't find some images we expected: #{i_care_about.keys}"
end

# sort these to make them pretty
puts JSON.pretty_generate(res.sort.to_h)
