[![Gem Version](https://badge.fury.io/rb/kitchen-rackspace.png)](http://badge.fury.io/rb/kitchen-rackspace)
[![Build Status](https://travis-ci.org/test-kitchen/kitchen-rackspace.png?branch=master)](https://travis-ci.org/test-kitchen/kitchen-rackspace)
[![Code Climate](https://codeclimate.com/github/test-kitchen/kitchen-rackspace.png)](https://codeclimate.com/github/test-kitchen/kitchen-rackspace)
[![Coverage Status](https://coveralls.io/repos/test-kitchen/kitchen-rackspace/badge.png)](https://coveralls.io/r/test-kitchen/kitchen-rackspace)
[![Dependency Status](https://gemnasium.com/test-kitchen/kitchen-rackspace.png)](https://gemnasium.com/test-kitchen/kitchen-rackspace)

# Kitchen::Rackspace

A Rackspace Cloud Servers driver for Test Kitchen 1.0!

Shamelessly copied from [Fletcher Nichol](https://github.com/fnichol)'s
awesome work on an [EC2 driver](https://github.com/opscode/kitchen-ec2).

## Installation

Add this line to your application's Gemfile:

    gem 'kitchen-rackspace'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kitchen-rackspace

## Usage

Provide, at a minimum, the required driver options in your `.kitchen.yml` file:

    driver:
      name: rackspace
      rackspace_username: [YOUR RACKSPACE CLOUD USERNAME]
      rackspace_api_key: [YOUR RACKSPACE CLOUD API KEY]
      require_chef_omnibus: latest (if you'll be using Chef)
    platforms:
      - name: [A PLATFORM NAME, e.g. 'centos-6']

By default, the driver will spawn a 1GB Performance server on the base image
for your specified platform. Additional, optional overrides can be provided:

    image_id: [SERVER IMAGE ID]
    flavor_id: [SERVER FLAVOR ID]
    server_name: [A UNIQUE SERVER NAME]
    public_key_path: [PATH TO YOUR PUBLIC SSH KEY]
    rackspace_region: [A VALID RACKSPACE DC/REGION]

You also have the option of providing some configs via environment variables:

    export RACKSPACE_USERNAME="user"   # (or OS_USERNAME)
    export RACKSPACE_API_KEY="api_key" # (or OS_PASSWORD)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
