# ?.?.? / ????-??-??

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

[#17]: https://github.com/test-kitchen/kitchen-rackspace/pull/17
[#15]: https://github.com/test-kitchen/kitchen-rackspace/pull/15
[#9]: https://github.com/test-kitchen/kitchen-rackspace/pull/9
[#8]: https://github.com/test-kitchen/kitchen-rackspace/pull/8
[#7]: https://github.com/test-kitchen/kitchen-rackspace/pull/7

[@coderanger]: https://github.com/coderanger
[@claco]: https://github.com/claco
