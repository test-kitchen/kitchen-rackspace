[![Gem Version](https://img.shields.io/gem/v/kitchen-rackspace.svg)][gem]
[![Build Status](https://img.shields.io/travis/test-kitchen/kitchen-rackspace.svg)][travis]
[![Code Climate](https://img.shields.io/codeclimate/github/test-kitchen/kitchen-rackspace.svg)][codeclimate]
[![Coverage Status](https://img.shields.io/coveralls/test-kitchen/kitchen-rackspace.svg)][coveralls]
[![Dependency Status](https://img.shields.io/gemnasium/test-kitchen/kitchen-rackspace.svg)][gemnasium]

[gem]: https://rubygems.org/gems/kitchen-rackspace
[travis]: https://travis-ci.org/test-kitchen/kitchen-rackspace
[codeclimate]: https://codeclimate.com/github/test-kitchen/kitchen-rackspace
[coveralls]: https://coveralls.io/r/test-kitchen/kitchen-rackspace
[gemnasium]: https://gemnasium.com/test-kitchen/kitchen-rackspace

Kitchen::Rackspace
==================

A Rackspace Cloud Servers driver for Test Kitchen!

Shamelessly copied from [Fletcher Nichol](https://github.com/fnichol)'s
awesome work on an [EC2 driver](https://github.com/opscode/kitchen-ec2).

Installation
------------

Add this line to your application's Gemfile:

    gem 'kitchen-rackspace'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kitchen-rackspace

Usage
-----

Provide, at a minimum, the required driver options in your `.kitchen.yml` file:

    driver:
      name: rackspace
      rackspace_username: [YOUR RACKSPACE CLOUD USERNAME]
      rackspace_api_key: [YOUR RACKSPACE CLOUD API KEY]
      require_chef_omnibus: [e.g. 'true' or a version number if you need Chef]
    platforms:
      - name: [A PLATFORM NAME, e.g. 'centos-6']

By default, the driver will spawn a 1GB Performance server on the base image
for your specified platform. Additional, optional overrides can be provided:

    image_id: [SERVER IMAGE ID]
    flavor_id: [SERVER FLAVOR ID]
    server_name: [A FRIENDLY SERVER NAME]
    public_key_path: [PATH TO YOUR PUBLIC SSH KEY]
    rackspace_region: [A VALID RACKSPACE DC/REGION]
    wait_for: [NUM OF SECONDS TO WAIT BEFORE TIMING OUT, DEFAULT 600]
    no_ssh_tcp_check: [DEFAULTS TO false, SKIPS TCP CHECK WHEN true]
    no_ssh_tcp_check_sleep: [NUM OF SECONDS TO SLEEP IF no_ssh_tcp_check IS SET]
    networks: [LIST OF RACKSPACE NETWORK UUIDS, DEFAULT PUBLICNET AND SERVICE NET]
    rackconnect_wait: ['true' IF USING RACKCONNECT TO WAIT FOR IT TO COMPLETE]
    servicelevel_wait: ['true' IF USING MANAGED SERVICE LEVEL AUTOMATION TO WAIT FOR IT TO COMPLETE]
    no_passwd_lock: ['true' IF FOG LIBRARY SHOULD NOT LOCK ROOT ACCOUNT]
    servicenet: ['true' IF USING THE SERVICENET IP ADDRESS TO CONNECT]
    config_drive: [DEFAULTS TO true, ENABLES READ-ONLY METADATA DRIVE]
    user_data: [EXTRA CONFIGURATION DATA FOR THE SERVER]

You also have the option of providing some configs via environment variables:

    export RACKSPACE_USERNAME="user"   # (or OS_USERNAME)
    export RACKSPACE_API_KEY="api_key" # (or OS_PASSWORD)

Some configs are also derived based on your .ssh directory, specifically the
`public_key_path` setting is derived by searching for:
- `~/.ssh/id_rsa.pub`
- `~/.ssh/id_dsa.pub`
- `~/.ssh/identity.pub`
- `~/.ssh/id_ecdsa.pub`

Contributing
------------

1. Fork it
2. `bundle install`
3. Create your feature branch (`git checkout -b my-new-feature`)
4. `bundle exec rake` must pass
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create new Pull Request
