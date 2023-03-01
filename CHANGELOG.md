# Change Log

# 1.0.0 / 2023-03-02

* Support for Ruby 3.0 and 3.1
* PR [#86](https://github.com/test-kitchen/kitchen-rackspace/pull/86) - Support for Test Kitchen 3.0; via [@tas50](https://github.com/tas50)
* PR [#84](https://github.com/test-kitchen/kitchen-rackspace/pull/84) - Optimize our requires; via [@tas50](https://github.com/tas50)
* PR [#82](https://github.com/test-kitchen/kitchen-rackspace/pull/82) - Unpin the bundler dev dep; via [@tas50](https://github.com/tas50)
* PR [#76](https://github.com/test-kitchen/kitchen-rackspace/pull/76) - Remove gemnasium badge; via [@tas50](https://github.com/tas50)
* PR [#77](https://github.com/test-kitchen/kitchen-rackspace/pull/77) - Use fog-rackspace instead of the monolithic fog gem ; via [@tas50](https://github.com/tas50)
* PR [#62](https://github.com/test-kitchen/kitchen-rackspace/pull/62) - Add support for setting region via ENV; via [@DavidWittman](https://github.com/DavidWittman)
* PR [#75](https://github.com/test-kitchen/kitchen-rackspace/pull/75) - Add support for user_data and config_drive options; via [@hartmantis](https://github.com/hartmantis)
* PR [#72](https://github.com/test-kitchen/kitchen-rackspace/pull/72) - Image data update and script fixes; via [@martinb3](https://github.com/martinb3)


# 0.21.0 / 2016-05-31

* PR [#67][] - Update image IDS; via [@martinb3][]
* PR [#65][] - Add Ubuntu 16.04; via [@coderanger][]

# 0.20.0 / 2016-01-15

* PR [#63][] - Update image IDs, add Ubuntu 15.10, drop Ubuntu 15.04; via
[@martinb3][]

# 0.19.0 / 2015-10-06

* PR [#60][] - Update to latest image IDs
* PR [#57][] - Add `servicelevel_wait` option; via [@martinb3][]
* PR [#56][] - Add `no_passwd_lock` option; via [@martinb3][]

# 0.18.0 / 2015-08-28

* PR [#53][] - Update image IDs, update Arch to 2015.7, drop Fedora 20, add
Fedora 22, update Gentoo to 15.3, update Vyatta to 6.7R9; via [@martinb3][]

# 0.17.0 / 2015-05-15

* PR [#51][] - Update image IDS--add Debian 8, drop Debian 6, add Ubuntu 15.04,
drop Ubuntu 14.10

# 0.16.0 / 2015-04-15

* PR [#50][] - Update image IDs, support 'centos-7.0' in addition to
'centos-7'; via [@martinb3][]

# 0.15.1 / 2015-04-03

* PR [#49][] - Update image IDs, re-add CentOS point release numbers; via
[@martinb3][]

# 0.15.0 / 2015-04-02

* PR [#48][] - Drop references to retired Ubuntu 10.04 image
* PR [#46][] - Update all image IDs, add Scientific 7, remove references to
point releases that Rackspace no longer uses in image names; via [@martinb3][]

# 0.14.0 / 2014-12-09

* PR [#45][] - Add Ubuntu 14.10 and Fedora 21
* PR [#44][] - Update all image IDs, add CentOS/Red Hat 5.11 and Red Hat 6.6,
update Vyatta to 6.7R4; via [@martinb3][]

# 0.13.0 / 2014-10-08

### Improvements

* PR [#43][] - Update all image IDs, bump Arch to 2014.10, Gentoo to 14.4,
Vyatta to 6.7
* PR [#42][] - Update CentOS 7 image ID; via [@marcoamorales][]

# 0.12.0 / 2014-09-10

### New Features

* PR [#41][] - Support optionally using ServiceNet for SSH access, via
[@steve-jansen][]

# 0.11.0 / 2014-09-04

### Improvements

* PR [#40][] - Port the server name generator from the OpenStack/DigitalOcean
drivers, with all its bug fixes; update image IDs

# 0.10.0 / 2014-08-28

### Improvements

* PR [#39][] - Update image ID list
* PR [#38][] - Recognize `debian-7.6` image name, via [@martinb3][]

# 0.9.0 / 2014-08-25

### Improvements

* PR [#37][] - Update image ID list
* PR [#36][] - Add CentOS 7 to the recognized images, via [@hhoover][]

# 0.8.0 / 2014-08-20

### New Features

* PR [#35][] - Add option to wait on RackConnect, via [@martinb3][]

# 0.7.0 / 2014-07-09

### New Features

* PR [#31][] - Support attaching to custom networks, via [@kanerogers][]
* PR [#29][] - Support using a sleep instead of TCP check in cases where new
servers might fail the TCP; via [@martinb3][]

# 0.6.1 / 2014-06-03

### Bug Fixes

* PR [#26][] - Fix issue with builds failing due to a timeout set at 0

# 0.6.0 / 2014-05-13

### New Features

* PR [#25][] - Allow overridding of Fog's default timeout; via [@pezholio][]

### Improvements

* PR [#24][] - Error out immediately when trying to install in Ruby 1.8

# 0.5.0 / 2014-05-01

### Improvements

* PR [#23][] - Switch to PVHVM images, where available
* PR [#22][] - Update all the images with new IDs
* PR [#21][] - Add Ubuntu 14.04 to the list of known images; via [@pezholio][]

# 0.4.0 / 2014-01-27

### New Features

* PR [#17][] - Support the common TK platform name style, e.g. `centos-6`,
via [@coderanger][]
* PR [#17][] - Support environment variables for username and API key, via
[@coderanger][]

### Improvements

* PR [#17][] - Change default flavor to lowest performance flavor for faster
boot times, via [@coderanger][]

# 0.3.0 / 2013-12-07

### Improvements

* Tested against, and working with, Test Kitchen 1.1.0

### Bug Fixes

* PR [#15][] - Update default `image_id` to a current one
* PR [#15][] - Fix collision with TK 1.x; change `name` option to `server_name`

# 0.2.0 / 2013-05-11

### New Features

* PR [#8][] - Support `rackspace_region:` option; at request of [@claco][]

### Improvements

* PR [#7][] - Clean up/refactor to pass style checks
* PR [#9][] - Add some (probably overkill) RSpec tests

# 0.1.0 / 2013-03-12

* Initial release! Woo!

[#67]: https://github.com/test-kitchen/kitchen-rackspace/pull/67
[#65]: https://github.com/test-kitchen/kitchen-rackspace/pull/65
[#63]: https://github.com/test-kitchen/kitchen-rackspace/pull/63
[#57]: https://github.com/test-kitchen/kitchen-rackspace/pull/57
[#56]: https://github.com/test-kitchen/kitchen-rackspace/pull/56
[#53]: https://github.com/test-kitchen/kitchen-rackspace/pull/53
[#51]: https://github.com/test-kitchen/kitchen-rackspace/pull/51
[#50]: https://github.com/test-kitchen/kitchen-rackspace/pull/50
[#49]: https://github.com/test-kitchen/kitchen-rackspace/pull/49
[#48]: https://github.com/test-kitchen/kitchen-rackspace/pull/48
[#46]: https://github.com/test-kitchen/kitchen-rackspace/pull/46
[#45]: https://github.com/test-kitchen/kitchen-rackspace/pull/45
[#44]: https://github.com/test-kitchen/kitchen-rackspace/pull/44
[#43]: https://github.com/test-kitchen/kitchen-rackspace/pull/43
[#42]: https://github.com/test-kitchen/kitchen-rackspace/pull/42
[#41]: https://github.com/test-kitchen/kitchen-rackspace/pull/41
[#40]: https://github.com/test-kitchen/kitchen-rackspace/pull/40
[#39]: https://github.com/test-kitchen/kitchen-rackspace/pull/39
[#38]: https://github.com/test-kitchen/kitchen-rackspace/pull/38
[#37]: https://github.com/test-kitchen/kitchen-rackspace/pull/37
[#36]: https://github.com/test-kitchen/kitchen-rackspace/pull/36
[#35]: https://github.com/test-kitchen/kitchen-rackspace/pull/35
[#31]: https://github.com/test-kitchen/kitchen-rackspace/pull/31
[#29]: https://github.com/test-kitchen/kitchen-rackspace/pull/29
[#26]: https://github.com/test-kitchen/kitchen-rackspace/pull/26
[#25]: https://github.com/test-kitchen/kitchen-rackspace/pull/25
[#24]: https://github.com/test-kitchen/kitchen-rackspace/pull/24
[#23]: https://github.com/test-kitchen/kitchen-rackspace/pull/23
[#22]: https://github.com/test-kitchen/kitchen-rackspace/pull/22
[#21]: https://github.com/test-kitchen/kitchen-rackspace/pull/21
[#17]: https://github.com/test-kitchen/kitchen-rackspace/pull/17
[#15]: https://github.com/test-kitchen/kitchen-rackspace/pull/15
[#9]: https://github.com/test-kitchen/kitchen-rackspace/pull/9
[#8]: https://github.com/test-kitchen/kitchen-rackspace/pull/8
[#7]: https://github.com/test-kitchen/kitchen-rackspace/pull/7

[@marcoamorales]: https://github.com/marcoamorales
[@steve-jansen]: https://github.com/steve-jansen
[@hhoover]: https://github.com/hhoover
[@kanerogers]: https://github.com/kanerogers
[@martinb3]: https://github.com/martinb3
[@pezholio]: https://github.com/pezholio
[@coderanger]: https://github.com/coderanger
[@claco]: https://github.com/claco
