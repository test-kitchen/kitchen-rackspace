# kitchen-rackspace

[![Gem Version](https://img.shields.io/gem/v/kitchen-rackspace.svg)](https://rubygems.org/gems/kitchen-rackspace)

A [Test Kitchen](https://kitchen.ci/) driver that creates and destroys [Rackspace Cloud Servers](https://www.rackspace.com/cloud/servers), so you can test your cookbooks and infrastructure code on Rackspace instances.

> **This project is no longer under active development.** It has no active
> maintainers. The driver may continue to work for some or all use cases, but
> issues filed on GitHub will most likely not be triaged. If you are interested
> in maintaining it, come and talk to us in `#test-kitchen` on
> [Chef Community Slack](https://community-slack.chef.io/).

<!-- -->

> **This driver targets Legacy Rackspace Cloud, not OpenStack Flex.** It
> authenticates against Rackspace Cloud Identity v2.0, which is the API of the
> original Rackspace Public Cloud.
>
> In 2025 Rackspace launched [Rackspace OpenStack Flex][flex] — now branded
> simply "Rackspace Cloud" — built on vanilla OpenStack with Keystone v3. That
> platform is **not** supported by this driver. Use
> [kitchen-openstack][kitchen-openstack] instead, with `openstack_auth_url` set
> to `https://keystone.api.<region>.rackspacecloud.com/v3` (regions include
> `sjc3`, `iad3`, and `dfw3`).
>
> Rackspace continues to operate and maintain the legacy platform, so this
> driver still works against it, but Rackspace has said that new development is
> focused on Flex.

[flex]: https://docs.rackspace.com/docs/rackspace-openstack-flex-vs-rackspace-cloud
[kitchen-openstack]: https://github.com/test-kitchen/kitchen-openstack

<!-- -->

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
  image_id: 09de0a66-3156-48b4-90a5-1cf25a905207  # see Choosing an image

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

With credentials in the environment, that is enough: the driver builds the
image you named on a 2 GB General Purpose flavor, using an SSH key from your
`~/.ssh` directory.

> **Set `image_id` yourself.** The driver ships a table that maps platform
> names like `ubuntu-22.04` to image IDs, but it has not been refreshed since
> 2016, so most modern platform names are not in it and the build fails with
> `image_id` missing. See [Choosing an image](#choosing-an-image).

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

## Choosing an image

`image_id` is a Rackspace image UUID, and it is the one option most people have
to set by hand.

The driver ships `data/images.json`, a table mapping Test Kitchen platform
names to image IDs so that a platform like `centos-7` resolves on its own.
**That table was last generated in 2016.** Its newest entries are Ubuntu 16.04,
CentOS 7, Debian 8, and Fedora 25. A modern platform name is not in it:

| Platform name | Resolves? |
| --- | --- |
| `ubuntu-16.04`, `centos-7`, `debian-8` | yes, to a 2016-era image |
| `ubuntu` (bare distro name) | yes, to Ubuntu 16.04 |
| `ubuntu-22.04`, `ubuntu-24.04`, `debian-12`, `rocky-9` | **no** |

When the platform name is not in the table, `image_id` has no default and
Test Kitchen fails validation. Set it explicitly.

### Finding an image ID

Image IDs differ per region, so look them up in the region you build in:

```sh
export RACKSPACE_USERNAME="myuser"
export RACKSPACE_API_KEY="myapikey"
export RACKSPACE_REGION="ord"

bundle exec ruby helpers/dump_image_list.rb
```

That prints every image the account can see, with its ID and the platform names
it would answer to. Copy the ID you want into `image_id`.

Refreshing the bundled table is contributor work — see
[Maintaining the bundled data](CONTRIBUTING.md#maintaining-the-bundled-data).

## Choosing a flavor

`flavor_id` selects CPU, memory, and disk. The default is `general1-2`.

### General Purpose v1

The right class for almost every test workload:

| Flavor | RAM | vCPUs | Disk |
| --- | --- | --- | --- |
| `general1-1` | 1 GB | 1 | 20 GB |
| `general1-2` *(default)* | 2 GB | 2 | 40 GB |
| `general1-4` | 4 GB | 4 | 80 GB |
| `general1-8` | 8 GB | 8 | 160 GB |

### Other current classes

| Class | Flavors | Shape |
| --- | --- | --- |
| I/O v1 | `io1-15`, `io1-30`, `io1-60`, `io1-90`, `io1-120` | 15–120 GB RAM, 4–32 vCPUs, 40 GB SSD |
| Compute v1 | `compute1-4`, `compute1-8`, `compute1-15`, `compute1-30`, `compute1-60` | CPU-weighted, no local data disk |
| Memory v1 | `memory1-15`, `memory1-30`, `memory1-60`, `memory1-120`, `memory1-240` | RAM-weighted, no local data disk |
| OnMetal | `onmetal-compute1`, `onmetal-io1`, `onmetal-memory1` | Single-tenant bare metal |

Compute v1 and Memory v1 flavors have no local data disk, so they need a Cloud
Block Storage volume to boot from. That is outside what this driver sets up.

### Retired classes

Do not use these. Rackspace removed them from the Control Panel and has said
they will be discontinued; some are still visible in the API.

| Class | Flavors | Replaced by |
| --- | --- | --- |
| Standard | numeric IDs `2` through `8` | General Purpose v1 |
| Performance 1 | `performance1-1`, `performance1-2`, `performance1-4`, `performance1-8` | General Purpose v1 |
| Performance 2 | `performance2-15` … `performance2-120` | I/O v1 |

### Listing what your account offers

Flavor availability varies by account and region:

```sh
bundle exec ruby helpers/dump_flavor_list.rb
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
| `image_id` | *looked up from the platform name* | Image UUID to build from. The bundled lookup table is stale, so in practice set this yourself — see [Choosing an image](#choosing-an-image). |
| `flavor_id` | `"general1-2"` | Flavor, which determines CPU, memory, and disk — see [Choosing a flavor](#choosing-a-flavor). |
| `server_name` | *generated* | Name for the server. If unset, a unique name of at most 63 characters is generated from the base name, your username, the hostname, and a random string. |
| `user_data` | `nil` | Extra configuration data passed to the server at build time. |
| `config_drive` | `true` | Attach the read-only metadata config drive. |
| `no_passwd_lock` | `false` | Do not let the underlying fog library lock the root account. Forced on when `rackconnect_wait` or `servicelevel_wait` is set — see [Networking](#networking). |

### Networking

| Option | Default | Description |
| --- | --- | --- |
| `networks` | *PublicNet and ServiceNet* | **Additional** Rackspace network UUIDs to attach. PublicNet and ServiceNet are always attached too — see below. |
| `servicenet` | `false` | Connect over the ServiceNet address rather than the public one. |
| `rackconnect_wait` | `false` | Wait for RackConnect to finish before continuing. Enable this if the account uses RackConnect. Forces `no_passwd_lock` on. |
| `servicelevel_wait` | `false` | Wait for Managed Service Level automation to finish before continuing. Forces `no_passwd_lock` on. |

`networks` adds to the standard networks rather than replacing them. Whatever
you list, the driver puts Rackspace's PublicNet
(`00000000-0000-0000-0000-000000000000`) and ServiceNet
(`11111111-1111-1111-1111-111111111111`) at the front of the list first, so
there is no way to build a server without a public interface. Do not list
either of those UUIDs yourself — you will just send Rackspace a duplicate.

`rackconnect_wait` and `servicelevel_wait` both turn `no_passwd_lock` on
regardless of how you set it, because RackConnect and Managed Service Level
each log in as root to do their work and a locked root account leaves them
stuck.

### SSH

| Option | Default | Description |
| --- | --- | --- |
| `public_key_path` | first key found in `~/.ssh` | Path to the SSH public key installed on the server. Searched in order: `id_rsa.pub`, `id_dsa.pub`, `identity.pub`, `id_ecdsa.pub`. |
| `username` | `"root"` | User to connect as. |
| `port` | `"22"` | SSH port. |

### Waiting

| Option | Default | Description |
| --- | --- | --- |
| `wait_for` | `600` | Seconds any single wait may take before timing out. This is fog's global timeout, so it applies to the build wait and to the `rackconnect_wait` and `servicelevel_wait` polls individually, not to `kitchen create` as a whole. |
| `no_ssh_tcp_check` | `false` | Skip the TCP check on the SSH port. Use when a firewall makes the check unreliable. |
| `no_ssh_tcp_check_sleep` | `120` | Seconds to sleep instead of checking, when `no_ssh_tcp_check` is enabled. |

## Examples

### A bigger instance in a specific region

```yaml
driver:
  name: rackspace
  rackspace_region: ord
  image_id: 09de0a66-3156-48b4-90a5-1cf25a905207
  flavor_id: general1-4
```

Image IDs are per-region, so `image_id` and `rackspace_region` travel together.

### Connecting over ServiceNet

```yaml
driver:
  name: rackspace
  servicenet: true
```

`servicenet` is all you need — ServiceNet is attached either way, and this
tells the driver to hand the transport the private address instead of the
public one. Use `networks` only to attach an *extra* network of your own:

```yaml
driver:
  name: rackspace
  servicenet: true
  networks:
    - 4b1c1b3a-8f0f-4a1e-9d33-6f3c7ab2e5d9  # your isolated cloud network
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

The most useful contribution right now is a refresh of `data/images.json`,
which has not been regenerated since 2016 — see
[Maintaining the bundled data](CONTRIBUTING.md#maintaining-the-bundled-data).

## Acknowledgements

Originally derived from [Fletcher Nichol](https://github.com/fnichol)'s work on the [EC2 driver](https://github.com/test-kitchen/kitchen-ec2).

## License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
