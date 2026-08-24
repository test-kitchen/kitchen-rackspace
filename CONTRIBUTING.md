# Contributing to kitchen-rackspace

> **This project is no longer under active development** and has no active
> maintainers. Issues filed on GitHub will most likely not be triaged. Pull
> requests are still welcome. If you are interested in maintaining the project,
> come and talk to us in `#test-kitchen` on
> [Chef Community Slack](https://community-slack.chef.io/).

## Reporting issues

Report bugs and request features on the [issue tracker](https://github.com/test-kitchen/kitchen-rackspace/issues), keeping the note above in mind. For bugs, please include:

- the version of kitchen-rackspace and Test Kitchen you are using
- your `kitchen.yml` with credentials removed
- the output of the failing command, ideally with `-l debug`

## Development setup

Clone the repository and install the dependencies:

```sh
git clone https://github.com/test-kitchen/kitchen-rackspace.git
cd kitchen-rackspace
bundle install
```

## Running the tests

Run the unit tests:

```sh
bundle exec rspec
```

Or through Rake, which adds colour and honours `SEED`, `VERBOSE`, and a
`--tag` argument:

```sh
bundle exec rake test
```

And the style check:

```sh
bundle exec cookstyle --chefstyle
```

**Pass `--chefstyle`.** CI runs it that way. Without the flag, cookstyle falls
back to stock RuboCop defaults, disagrees with this codebase about string
quoting, and reports over a hundred offenses that are not real.

Many style offenses can be corrected automatically:

```sh
bundle exec cookstyle --chefstyle -a
```

The unit tests stub the Rackspace API, so they do not build servers and do not
require an account.

The YARD documentation has its own tasks:

```sh
bundle exec rake doc            # build the docs
bundle exec rake doc_coverage   # list anything in lib/ still undocumented
```

### Manual testing against Rackspace

Changes that touch server creation should also be exercised against a real
account, since the stubbed tests cannot catch API-level regressions. **This
builds billable servers.** Export `RACKSPACE_USERNAME`, `RACKSPACE_API_KEY` and
`RACKSPACE_REGION`, run `kitchen test`, then confirm in the Rackspace control
panel that no servers were left behind — a run that fails partway through can
leave one running.

## Submitting changes

1. Fork the repository.
2. Create a feature branch off `main`.
3. Make your change, adding or updating tests to cover it.
4. Make sure `bundle exec rspec` and `bundle exec cookstyle` pass.
5. Push the branch to your fork and open a pull request.

Please keep pull requests focused on a single change — it makes review much
faster. Update the documentation in `README.md` when you add or change a
configuration option.

### Commit messages

This project uses [Conventional Commits](https://www.conventionalcommits.org/).
release-please reads the commit subjects on `main` to decide the next version
and to write the changelog, so the prefix matters:

| Prefix | Effect |
| --- | --- |
| `fix:` | patch release |
| `feat:` | minor release |
| `docs:`, `chore:`, `style:`, `test:` | no release |
| `feat!:`, or a `BREAKING CHANGE:` footer | major release |

Pull requests are squash-merged, so it is the PR title that lands on `main` and
gets parsed. Write it as a Conventional Commit.

## Maintaining the bundled data

### data/images.json

The driver maps a Test Kitchen platform name to a Rackspace image ID using
`data/images.json`. **That table has not been regenerated since 2016** — its
newest entries are Ubuntu 16.04, CentOS 7, Debian 8, and Fedora 25 — so modern
platform names do not resolve and users have to set `image_id` by hand.

Refreshing it is the most useful contribution available here. It needs a
Rackspace account:

```sh
export RACKSPACE_USERNAME="myuser"
export RACKSPACE_API_KEY="myapikey"
export RACKSPACE_REGION="ord"

bundle exec ruby helpers/dump_image_list.rb          # review what the account sees
bundle exec ruby helpers/dump_image_list.rb --json > data/images.json
```

Image IDs are per-region, so regenerate from the region most users build in.
The helper derives platform names from each image's OpenStack metadata:
`ubuntu-22.04` and `ubuntu-22` from the version, plus the bare `ubuntu` for the
newest version of that distro. Images without that metadata — custom snapshots,
mostly — are skipped.

A refresh also needs the platform-resolution specs updated, since they assert
against the current table.

### helpers/dump_flavor_list.rb

Lists the flavors an account can build, for checking the flavor tables in the
README against reality:

```sh
bundle exec ruby helpers/dump_flavor_list.rb
```

### Running the helpers

Both helpers must run under Bundler:

```sh
bundle exec ruby helpers/dump_image_list.rb
```

Outside Bundler they resolve a newer fog-core, and `require "fog/rackspace"`
raises `NameError: wrong constant name CDN v2`. fog-rackspace registers a
service with a space in its name that newer fog-core cannot constantize, which
is why the gemspec pins `fog-core < 2.3`.

## Release process

Releases are automated by [release-please](.github/workflows/publish.yaml), and
maintainers only have to merge a pull request.

1. Every push to `main` updates a standing release pull request titled
   `chore(main): release X.Y.Z`. It accumulates the changes since the last
   release and derives the version from their commit prefixes.
2. Merging that pull request tags the release and publishes the gem to RubyGems
   and GitHub Packages.

**Do not hand-edit `CHANGELOG.md` or
`lib/kitchen/driver/rackspace_version.rb`.** release-please owns both — they are
its `changelog-path` and `version-file` in
[release-please-config.json](release-please-config.json) — and editing them
directly conflicts with the release pull request.

The release pull request does not resolve its own conflicts. If it picks one up,
rebase it by hand, keeping `main`'s content and the bot's version bump.
