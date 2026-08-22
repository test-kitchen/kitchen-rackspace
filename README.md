# kitchen-rackspace

[![Gem Version](https://img.shields.io/gem/v/kitchen-rackspace.svg)](https://rubygems.org/gems/kitchen-rackspace)

A [Test Kitchen](https://kitchen.ci/) driver that creates and destroys [Rackspace Cloud Servers](https://www.rackspace.com/cloud/servers), so you can test your cookbooks and infrastructure code on Rackspace instances.

> **This project is no longer under active development.** It has no active
> maintainers. The driver may continue to work for some or all use cases, but
> issues filed on GitHub will most likely not be triaged. If you are interested
> in maintaining it, come and talk to us in `#test-kitchen` on
> [Chef Community Slack](https://community-slack.chef.io/).

> This documentation uses [Cinc Workstation](https://cinc.sh/) and the `cinc` commands throughout. Everything here works identically with Chef Workstation — see [Using with Chef](#using-with-chef).

## Requirements

- Ruby 3.1 or later (already satisfied if you use Cinc Workstation)
- A Rackspace Cloud account, with its username and API key
- An SSH public key, used to grant access to the created server

## Installation

This driver ships as part of [Cinc Workstation](https://cinc.sh/start/workstation/). If you have Cinc Workstation installed, there is nothing else to install.

To install it into a standalone Ruby:

```sh
gem install kitchen-rackspace
```

Or with Bundler, add it to your `Gemfile`:

```ruby
gem "kitchen-rackspace"
```

...then run `bundle install`.

## Authentication

Credentials come from either the driver options or the environment. The
environment is preferred, so credentials stay out of `kitchen.yml`:

```sh
export RACKSPACE_USERNAME="myuser"    # or OS_USERNAME
export RACKSPACE_API_KEY="myapikey"   # or OS_PASSWORD
export RACKSPACE_REGION="dfw"         # or OS_REGION_NAME
```

If `RACKSPACE_REGION` is unset, the driver defaults to `dfw`.

## Quick Start

```yaml
---
driver:
  name: rackspace

provisioner:
  name: cinc_infra

verifier:
  name: cinc_auditor

platforms:
  - name: ubuntu-22.04

suites:
  - name: default
    run_list:
      - recipe[my_cookbook::default]
```

With credentials in the environment, that is enough: the driver picks a base
image for the platform, a 1 GB Performance flavor, and an SSH key from your
`~/.ssh` directory.

Then run the full test cycle:

```sh
cinc kitchen test
```

Or step through it:

```sh
cinc kitchen create    # build the Rackspace server
cinc kitchen converge  # apply your cookbook
cinc kitchen verify    # run your tests
cinc kitchen destroy   # delete the server
```

## Configuration

All options below are set under the `driver:` key in `kitchen.yml`.

### Credentials

| Option | Default | Description |
| --- | --- | --- |
| `rackspace_username` | `$RACKSPACE_USERNAME`, else `$OS_USERNAME` | Rackspace Cloud username. Required, from here or the environment. |
| `rackspace_api_key` | `$RACKSPACE_API_KEY`, else `$OS_PASSWORD` | Rackspace Cloud API key. Required, from here or the environment. |
| `rackspace_region` | `$RACKSPACE_REGION`, else `$OS_REGION_NAME`, else `"dfw"` | Region to build in, e.g. `dfw`, `ord`, `iad`, `lon`, `syd`, `hkg`. |
| `version` | `"v2"` | Rackspace Cloud Servers API version. |

### Server

| Option | Default | Description |
| --- | --- | --- |
| `image_id` | *base image for the platform* | Image ID to build from. Required if the platform name is not one the driver knows. |
| `flavor_id` | `"performance1-1"` | Flavor ID, which determines CPU and memory. |
| `server_name` | *generated* | Name for the server. If unset, a unique name of at most 63 characters is generated from the base name, your username, the hostname, and a random string. |
| `user_data` | `nil` | Extra configuration data passed to the server at build time. |
| `config_drive` | `true` | Attach the read-only metadata config drive. |
| `no_passwd_lock` | `false` | Do not let the underlying fog library lock the root account. |

### Networking

| Option | Default | Description |
| --- | --- | --- |
| `networks` | PublicNet and ServiceNet | Array of Rackspace network UUIDs to attach. |
| `servicenet` | `false` | Connect over the ServiceNet address rather than the public one. |
| `rackconnect_wait` | `false` | Wait for RackConnect to finish before continuing. Enable this if the account uses RackConnect. |
| `servicelevel_wait` | `false` | Wait for Managed Service Level automation to finish before continuing. |

### SSH

| Option | Default | Description |
| --- | --- | --- |
| `public_key_path` | first key found in `~/.ssh` | Path to the SSH public key installed on the server. Searched in order: `id_rsa.pub`, `id_dsa.pub`, `identity.pub`, `id_ecdsa.pub`. |
| `username` | `"root"` | User to connect as. |
| `port` | `"22"` | SSH port. |

### Waiting

| Option | Default | Description |
| --- | --- | --- |
| `wait_for` | `600` | Seconds to wait for the server to become available before timing out. |
| `no_ssh_tcp_check` | `false` | Skip the TCP check on the SSH port. Use when a firewall makes the check unreliable. |
| `no_ssh_tcp_check_sleep` | `120` | Seconds to sleep instead of checking, when `no_ssh_tcp_check` is enabled. |

## Examples

### Pinning the image and flavor

```yaml
driver:
  name: rackspace
  rackspace_region: ord
  image_id: 09de0a66-3156-48b4-90a5-1cf25a905207
  flavor_id: general1-2
```

### Connecting over ServiceNet

```yaml
driver:
  name: rackspace
  servicenet: true
  networks:
    - 11111111-1111-1111-1111-111111111111
```

### RackConnect accounts

Without this, the converge can start before RackConnect has finished wiring up
the server's networking.

```yaml
driver:
  name: rackspace
  rackconnect_wait: true
  servicelevel_wait: true
```

### A specific SSH key

```yaml
driver:
  name: rackspace
  public_key_path: ~/.ssh/kitchen_rackspace.pub

transport:
  ssh_key: ~/.ssh/kitchen_rackspace
```

### Slow builds, or a firewall in the way

```yaml
driver:
  name: rackspace
  wait_for: 1200
  no_ssh_tcp_check: true
  no_ssh_tcp_check_sleep: 180
```

## Using with Chef

This driver is not tied to Cinc. The examples above use Cinc Workstation and the `cinc_infra` provisioner, but the driver works exactly the same with [Chef Workstation](https://www.chef.io/downloads/tools/workstation) — run `kitchen` instead of `cinc kitchen`, and use `chef_infra` instead of `cinc_infra`:

```yaml
provisioner:
  name: chef_infra

verifier:
  name: inspec
```

No driver configuration changes are needed.

## Contributing

This project has no active maintainers, so please read the status note at the
top before opening an issue. Pull requests are still welcome on
[GitHub](https://github.com/test-kitchen/kitchen-rackspace). See
[CONTRIBUTING.md](CONTRIBUTING.md) for development setup and how to run the
tests.

## Acknowledgements

Originally derived from [Fletcher Nichol](https://github.com/fnichol)'s work on the [EC2 driver](https://github.com/test-kitchen/kitchen-ec2).

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
