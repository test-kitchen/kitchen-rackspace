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
* PR [#21][] - Add Ubunutu 14.04 to the list of known images; via [@pezholio][]

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

[@hhoover]: https://github.com/hhoover
[@kanerogers]: https://github.com/kanerogers
[@martinb3]: https://github.com/martinb3
[@pezholio]: https://github.com/pezholio
[@coderanger]: https://github.com/coderanger
[@claco]: https://github.com/claco
