# Kitchen-rackspace Changelog

## Unreleased

* Update actions/checkout action to v7 ([#118](https://github.com/test-kitchen/kitchen-rackspace/pull/118)) ([ffe0696](https://github.com/test-kitchen/kitchen-rackspace/commit/ffe0696))
* Update googleapis/release-please-action action to v5 ([#117](https://github.com/test-kitchen/kitchen-rackspace/pull/117)) ([836d55b](https://github.com/test-kitchen/kitchen-rackspace/commit/836d55b))
* Require Ruby 3.1+ and modernize CI ([#119](https://github.com/test-kitchen/kitchen-rackspace/pull/119)) ([d277ba1](https://github.com/test-kitchen/kitchen-rackspace/commit/d277ba1))
* Let cookstyle decide which files to lint ([#120](https://github.com/test-kitchen/kitchen-rackspace/pull/120)) ([80d515c](https://github.com/test-kitchen/kitchen-rackspace/commit/80d515c))
* Docs: rewrite README for new users and split contributor docs ([#121](https://github.com/test-kitchen/kitchen-rackspace/pull/121)) ([638440a](https://github.com/test-kitchen/kitchen-rackspace/commit/638440a))
* Remove dependabot config in favor of renovate ([#122](https://github.com/test-kitchen/kitchen-rackspace/pull/122)) ([92dcec9](https://github.com/test-kitchen/kitchen-rackspace/commit/92dcec9))

## [0.22.0](https://github.com/test-kitchen/kitchen-rackspace/compare/v0.21.2...v0.22.0) (2026-08-24)


### Features

* implement the driver api version, plugin version, status, and doctor hooks ([#128](https://github.com/test-kitchen/kitchen-rackspace/issues/128)) ([5dcd484](https://github.com/test-kitchen/kitchen-rackspace/commit/5dcd484b352f0394feea9a634525a50d5e15b01c))


### Bug Fixes

* default to the general1-2 flavor instead of the retired performance1-1 ([#130](https://github.com/test-kitchen/kitchen-rackspace/issues/130)) ([5228814](https://github.com/test-kitchen/kitchen-rackspace/commit/52288148a5d177c67be1cdeb98d06aef94a5bf97))
* require test-kitchen 3.0 or newer ([#125](https://github.com/test-kitchen/kitchen-rackspace/issues/125)) ([37c1753](https://github.com/test-kitchen/kitchen-rackspace/commit/37c1753de5e63d5d2bb3772c19912b443328a41b))

## [0.21.2](https://github.com/test-kitchen/kitchen-rackspace/compare/v0.21.1...v0.21.2) (2026-01-22)

### Bug Fixes

* bump tk dep to allow tk 4 ([#115](https://github.com/test-kitchen/kitchen-rackspace/issues/115)) ([c6bc76c](https://github.com/test-kitchen/kitchen-rackspace/commit/c6bc76c10f4b4cd66c8b429ae50a713ff63dbe46))

### Other Changes

* chore(deps): update actions/checkout action to v5 ([#113](https://github.com/test-kitchen/kitchen-rackspace/pull/113)) ([76a0e97](https://github.com/test-kitchen/kitchen-rackspace/commit/76a0e97))
* Update fog-core requirement from &gt;= 1.35, &lt; 2.1.1 to &gt;= 1.35, &lt; 2.6.1 ([#112](https://github.com/test-kitchen/kitchen-rackspace/pull/112)) ([f2765bb](https://github.com/test-kitchen/kitchen-rackspace/commit/f2765bb))
* chore(deps): update actions/checkout action to v6 ([#114](https://github.com/test-kitchen/kitchen-rackspace/pull/114)) ([c1e87f1](https://github.com/test-kitchen/kitchen-rackspace/commit/c1e87f1))

## [0.21.1](https://github.com/test-kitchen/kitchen-rackspace/compare/v0.21.0...v0.21.1) (2024-07-01)

### Features

* Add Workflows ([#105](https://github.com/test-kitchen/kitchen-rackspace/issues/105)) ([1a4f418](https://github.com/test-kitchen/kitchen-rackspace/commit/1a4f4181845c4da9d79748c0f4cfa03c8653d8f3))


### Bug Fixes

* release please configs ([#108](https://github.com/test-kitchen/kitchen-rackspace/issues/108)) ([e8773c1](https://github.com/test-kitchen/kitchen-rackspace/commit/e8773c18e89d8dde724bfa06028678fb43da18a0))

### Other Changes

* Image data update and script fixes ([#72](https://github.com/test-kitchen/kitchen-rackspace/pull/72)) ([8048e4a](https://github.com/test-kitchen/kitchen-rackspace/commit/8048e4a))
* Add support for setting region via ENV ([#62](https://github.com/test-kitchen/kitchen-rackspace/pull/62)) ([da415e9](https://github.com/test-kitchen/kitchen-rackspace/commit/da415e9))
* Add support for user_data and config_drive options ([#75](https://github.com/test-kitchen/kitchen-rackspace/pull/75)) ([569de68](https://github.com/test-kitchen/kitchen-rackspace/commit/569de68))
* Drop Ruby 1.9/2.0 support and get the build green ([#77](https://github.com/test-kitchen/kitchen-rackspace/pull/77)) ([169da5d](https://github.com/test-kitchen/kitchen-rackspace/commit/169da5d))
* Remove gemnasium badge ([#76](https://github.com/test-kitchen/kitchen-rackspace/pull/76)) ([564dd7b](https://github.com/test-kitchen/kitchen-rackspace/commit/564dd7b))
* Update README.md ([d954a2d](https://github.com/test-kitchen/kitchen-rackspace/commit/d954a2d))
* Unpin the bundler dev dep ([#82](https://github.com/test-kitchen/kitchen-rackspace/pull/82)) ([c0ca2b6](https://github.com/test-kitchen/kitchen-rackspace/commit/c0ca2b6))
* Test on modern ruby releases ([#83](https://github.com/test-kitchen/kitchen-rackspace/pull/83)) ([0f3ba1e](https://github.com/test-kitchen/kitchen-rackspace/commit/0f3ba1e))
* Update test-kitchen requirement from ~&gt; 1.1 to &gt;= 1.1, &lt; 3.0 ([#78](https://github.com/test-kitchen/kitchen-rackspace/pull/78)) ([4c0a9a2](https://github.com/test-kitchen/kitchen-rackspace/commit/4c0a9a2))
* Update rake requirement from ~&gt; 11.0 to ~&gt; 12.3 ([#79](https://github.com/test-kitchen/kitchen-rackspace/pull/79)) ([2335fc7](https://github.com/test-kitchen/kitchen-rackspace/commit/2335fc7))
* Optimize our requires ([#84](https://github.com/test-kitchen/kitchen-rackspace/pull/84)) ([7e2f55e](https://github.com/test-kitchen/kitchen-rackspace/commit/7e2f55e))
* Upgrade to GitHub-native Dependabot ([#85](https://github.com/test-kitchen/kitchen-rackspace/pull/85)) ([3dbf701](https://github.com/test-kitchen/kitchen-rackspace/commit/3dbf701))
* Support Test Kitchen 3.0 and require Ruby 2.5+ ([#86](https://github.com/test-kitchen/kitchen-rackspace/pull/86)) ([f64d95a](https://github.com/test-kitchen/kitchen-rackspace/commit/f64d95a))
* Update rake requirement from ~&gt; 12.3 to ~&gt; 13.0 ([#88](https://github.com/test-kitchen/kitchen-rackspace/pull/88)) ([a964c1c](https://github.com/test-kitchen/kitchen-rackspace/commit/a964c1c))
* Update rubocop requirement from ~&gt; 0.57.2 to ~&gt; 1.18.2 ([#87](https://github.com/test-kitchen/kitchen-rackspace/pull/87)) ([5c255ad](https://github.com/test-kitchen/kitchen-rackspace/commit/5c255ad))
* Update rubocop requirement from ~&gt; 1.18.2 to ~&gt; 1.19.0 ([#89](https://github.com/test-kitchen/kitchen-rackspace/pull/89)) ([ecf7239](https://github.com/test-kitchen/kitchen-rackspace/commit/ecf7239))
* Update rubocop requirement from ~&gt; 1.19.0 to ~&gt; 1.22.0 ([#92](https://github.com/test-kitchen/kitchen-rackspace/pull/92)) ([a6db161](https://github.com/test-kitchen/kitchen-rackspace/commit/a6db161))
* Update rubocop requirement from ~&gt; 1.22.0 to ~&gt; 1.25.0 ([#96](https://github.com/test-kitchen/kitchen-rackspace/pull/96)) ([aedff22](https://github.com/test-kitchen/kitchen-rackspace/commit/aedff22))
* Update rubocop requirement from ~&gt; 1.25.0 to ~&gt; 1.26.0 ([#97](https://github.com/test-kitchen/kitchen-rackspace/pull/97)) ([f08f440](https://github.com/test-kitchen/kitchen-rackspace/commit/f08f440))
* Update rubocop requirement from ~&gt; 1.26.0 to ~&gt; 1.27.0 ([#98](https://github.com/test-kitchen/kitchen-rackspace/pull/98)) ([c5ec7a8](https://github.com/test-kitchen/kitchen-rackspace/commit/c5ec7a8))
* Update rubocop requirement from ~&gt; 1.27.0 to ~&gt; 1.28.2 ([#100](https://github.com/test-kitchen/kitchen-rackspace/pull/100)) ([b97a0f4](https://github.com/test-kitchen/kitchen-rackspace/commit/b97a0f4))
* Reuse the exising workflows ([#101](https://github.com/test-kitchen/kitchen-rackspace/pull/101)) ([d9d983b](https://github.com/test-kitchen/kitchen-rackspace/commit/d9d983b))
* Remove old badges ([12fc6ef](https://github.com/test-kitchen/kitchen-rackspace/commit/12fc6ef))
* Delete .travis.yml ([19e58bc](https://github.com/test-kitchen/kitchen-rackspace/commit/19e58bc))
* Remove travis badge ([8c154d6](https://github.com/test-kitchen/kitchen-rackspace/commit/8c154d6))

## 0.21.0 / 2016-05-31

* PR [#67] - Update image IDS; via [@martinb3]
* PR [#65] - Add Ubuntu 16.04; via [@coderanger]

* Fix rubocop ([#66](https://github.com/test-kitchen/kitchen-rackspace/pull/66)) ([3908cec](https://github.com/test-kitchen/kitchen-rackspace/commit/3908cec))
* Adding Ubuntu 16.04. ([#68](https://github.com/test-kitchen/kitchen-rackspace/pull/68)) ([e1884a2](https://github.com/test-kitchen/kitchen-rackspace/commit/e1884a2))

## 0.20.0 / 2016-01-15

* PR [#63] - Update image IDs, add Ubuntu 15.10, drop Ubuntu 15.04; via
[@martinb3]

## 0.19.0 / 2015-10-06

* PR [#60] - Update to latest image IDs
* PR [#57] - Add `servicelevel_wait` option; via [@martinb3]
* PR [#56] - Add `no_passwd_lock` option; via [@martinb3]

* Update image list ([#53](https://github.com/test-kitchen/kitchen-rackspace/pull/53)) ([735aadd](https://github.com/test-kitchen/kitchen-rackspace/commit/735aadd))
* Drop the Ruby 1.9 CI build ([#58](https://github.com/test-kitchen/kitchen-rackspace/pull/58)) ([14a5b8b](https://github.com/test-kitchen/kitchen-rackspace/commit/14a5b8b))

## 0.18.0 / 2015-08-28

* PR [#53] - Update image IDs, update Arch to 2015.7, drop Fedora 20, add
Fedora 22, update Gentoo to 15.3, update Vyatta to 6.7R9; via [@martinb3]

## 0.17.0 / 2015-05-15

* PR [#51] - Update image IDS--add Debian 8, drop Debian 6, add Ubuntu 15.04,
drop Ubuntu 14.10

## 0.16.0 / 2015-04-15

* PR [#50] - Update image IDs, support 'centos-7.0' in addition to
'centos-7'; via [@martinb3]

* Update badge URLs ([8edf7d0](https://github.com/test-kitchen/kitchen-rackspace/commit/8edf7d0))

## 0.15.1 / 2015-04-03

* PR [#49] - Update image IDs, re-add CentOS point release numbers; via
[@martinb3]

* Enable Travis containers and gemset caching ([8cad60c](https://github.com/test-kitchen/kitchen-rackspace/commit/8cad60c))

## 0.15.0 / 2015-04-02

* PR [#48] - Drop references to retired Ubuntu 10.04 image
* PR [#46] - Update all image IDs, add Scientific 7, remove references to
point releases that Rackspace no longer uses in image names; via [@martinb3]

* Fix unit tests ([#47](https://github.com/test-kitchen/kitchen-rackspace/pull/47)) ([23de895](https://github.com/test-kitchen/kitchen-rackspace/commit/23de895))
* s/2014/2015 ([4ee45e1](https://github.com/test-kitchen/kitchen-rackspace/commit/4ee45e1))
* Fix bad syntax in gemspec ([9883188](https://github.com/test-kitchen/kitchen-rackspace/commit/9883188))
* Add dev dep gem constraints to satisfy warnings ([46540ad](https://github.com/test-kitchen/kitchen-rackspace/commit/46540ad))

## 0.14.0 / 2014-12-09

* PR [#45] - Add Ubuntu 14.10 and Fedora 21
* PR [#44] - Update all image IDs, add CentOS/Red Hat 5.11 and Red Hat 6.6,
update Vyatta to 6.7R4; via [@martinb3]

## 0.13.0 / 2014-10-08

### Improvements

* PR [#43] - Update all image IDs, bump Arch to 2014.10, Gentoo to 14.4,
Vyatta to 6.7
* PR [#42] - Update CentOS 7 image ID; via [@marcoamorales]

## 0.12.0 / 2014-09-10

### New Features

* PR [#41] - Support optionally using ServiceNet for SSH access, via
[@steve-jansen]

## 0.11.0 / 2014-09-04

### Improvements

* PR [#40] - Port the server name generator from the OpenStack/DigitalOcean
drivers, with all its bug fixes; update image IDs

## 0.10.0 / 2014-08-28

### Improvements

* PR [#39] - Update image ID list
* PR [#38] - Recognize `debian-7.6` image name, via [@martinb3]

## 0.9.0 / 2014-08-25

### Improvements

* PR [#37] - Update image ID list
* PR [#36] - Add CentOS 7 to the recognized images, via [@hhoover]

## 0.8.0 / 2014-08-20

### New Features

* PR [#35] - Add option to wait on RackConnect, via [@martinb3]

### Other Changes

* Drop support for Ruby 1.9.2 ([52cb429](https://github.com/test-kitchen/kitchen-rackspace/commit/52cb429))

## 0.7.0 / 2014-07-09

### New Features

* PR [#31] - Support attaching to custom networks, via [@kanerogers]
* PR [#29] - Support using a sleep instead of TCP check in cases where new
servers might fail the TCP; via [@martinb3]

### Other Changes

* Some documentation clarification. ([#28](https://github.com/test-kitchen/kitchen-rackspace/pull/28)) ([2ed61cd](https://github.com/test-kitchen/kitchen-rackspace/commit/2ed61cd))
* Fix #18 ([#30](https://github.com/test-kitchen/kitchen-rackspace/pull/30)) ([ff365a8](https://github.com/test-kitchen/kitchen-rackspace/commit/ff365a8))
* Add two new configuration options, RE: TCP checks ([#32](https://github.com/test-kitchen/kitchen-rackspace/pull/32)) ([475841f](https://github.com/test-kitchen/kitchen-rackspace/commit/475841f))
* Support custom networks ([#33](https://github.com/test-kitchen/kitchen-rackspace/pull/33)) ([11bbbb8](https://github.com/test-kitchen/kitchen-rackspace/commit/11bbbb8))

## 0.6.1 / 2014-06-03

### Bug Fixes

* PR [#26] - Fix issue with builds failing due to a timeout set at 0

## 0.6.0 / 2014-05-13

### New Features

* PR [#25] - Allow overridding of Fog's default timeout; via [@pezholio]

### Improvements

* PR [#24] - Error out immediately when trying to install in Ruby 1.8

### Other Changes

* Remove reference to TK 1.0--it's 1.1.x now ([482add8](https://github.com/test-kitchen/kitchen-rackspace/commit/482add8))
* Update version for release ([9b33f85](https://github.com/test-kitchen/kitchen-rackspace/commit/9b33f85))

## 0.5.0 / 2014-05-01

### Improvements

* PR [#23] - Switch to PVHVM images, where available
* PR [#22] - Update all the images with new IDs
* PR [#21] - Add Ubuntu 14.04 to the list of known images; via [@pezholio]

### Other Changes

* Fix #13 - Rename 'name' option to 'server_name' ([#15](https://github.com/test-kitchen/kitchen-rackspace/pull/15)) ([bca9e15](https://github.com/test-kitchen/kitchen-rackspace/commit/bca9e15))
* Bump for 0.3.0 release ([43266dc](https://github.com/test-kitchen/kitchen-rackspace/commit/43266dc))
* Add Coveralls support, maybe ([#16](https://github.com/test-kitchen/kitchen-rackspace/pull/16)) ([d3d2e85](https://github.com/test-kitchen/kitchen-rackspace/commit/d3d2e85))
* Improve defaults ([#17](https://github.com/test-kitchen/kitchen-rackspace/pull/17)) ([e320b29](https://github.com/test-kitchen/kitchen-rackspace/commit/e320b29))
* README and CHANGELOG updates ([3d04c23](https://github.com/test-kitchen/kitchen-rackspace/commit/3d04c23))
* Update URLs to test-kitchen org ([#19](https://github.com/test-kitchen/kitchen-rackspace/pull/19)) ([7c31774](https://github.com/test-kitchen/kitchen-rackspace/commit/7c31774))

## 0.4.0 / 2014-01-27

### New Features

* PR [#17] - Support the common TK platform name style, e.g. `centos-6`,
via [@coderanger]
* PR [#17] - Support environment variables for username and API key, via
[@coderanger]

### Improvements

* PR [#17] - Change default flavor to lowest performance flavor for faster
boot times, via [@coderanger]

## 0.3.0 / 2013-12-07

### Improvements

* Tested against, and working with, Test Kitchen 1.1.0

### Bug Fixes

* PR [#15] - Update default `image_id` to a current one
* PR [#15] - Fix collision with TK 1.x; change `name` option to `server_name`

## 0.2.0 / 2013-05-11

### New Features

* PR [#8] - Support `rackspace_region:` option; at request of [@claco]

### Improvements

* PR [#7] - Clean up/refactor to pass style checks
* PR [#9] - Add some (probably overkill) RSpec tests

### Other Changes

* First draft, seems to be working ([a084294](https://github.com/test-kitchen/kitchen-rackspace/commit/a084294))
* Update README ([580d9c9](https://github.com/test-kitchen/kitchen-rackspace/commit/580d9c9))
* Ignore .kitchen ([d3e6891](https://github.com/test-kitchen/kitchen-rackspace/commit/d3e6891))
* Fog doesn't actually need a private key ([4f103f3](https://github.com/test-kitchen/kitchen-rackspace/commit/4f103f3))
* Update date for release ([873a2be](https://github.com/test-kitchen/kitchen-rackspace/commit/873a2be))

## 0.1.0 / 2013-03-12

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
