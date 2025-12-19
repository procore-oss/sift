# Contributing

## Development Setup

Installing gems before running tests:

```bash
$ bundle exec appraisal install
```

Running tests:

```bash
$ bundle exec appraisal rake test
```

## Publishing

Publishing is done using the `gem` command line tool. You must have permissions to publish a new version. Users with permissions can be seen at https://rubygems.org/gems/procore-sift.

When a bump is desired, the gemspec should have the version number bumped and merged into master.

**Step 1:** Build the new version

```bash
gem build sift.gemspec
```

```
Successfully built RubyGem
Name: procore-sift
Version: 1.0.0
File: procore-sift-1.0.0.gem
```

**Step 2:** Push the updated build

```bash
gem push procore-sift-1.0.0.gem
```

```
Pushing gem to https://rubygems.org...
Successfully registered gem: procore-sift (1.0.0)
```
