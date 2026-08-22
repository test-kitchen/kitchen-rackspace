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

And the style check:

```sh
bundle exec cookstyle
```

Many style offenses can be corrected automatically:

```sh
bundle exec cookstyle -a
```

The unit tests stub the Rackspace API, so they do not build servers and do not
require an account.

> **Note:** the `rspec` task in the `Rakefile` is configured with
> `--default-path test` and `-I test/spec`, but the specs actually live in
> `spec/`. Run `bundle exec rspec` directly, as CI does, until that is fixed.

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

## Release process

Releases are handled by the maintainers.

1. Update `lib/kitchen/driver/rackspace_version.rb` with the new version.
2. Update `CHANGELOG.md`.
3. Merge to `main`; the [publish workflow](.github/workflows/publish.yaml) builds
   the gem and pushes it to RubyGems.
