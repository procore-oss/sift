# Sift

[![Build Status](https://travis-ci.org/procore/sift.svg?branch=master)](https://travis-ci.org/procore/sift)

A declarative DSL for building filters and sorts with Rails and Active Record.

## Usage

Include Sift in your controllers and define filters and sorts:

```ruby
class PostsController < ApplicationController
  include Sift

  filter_on :title, type: :string
  filter_on :priority, type: :int
  filter_on :published_at, type: :datetime
  filter_on :with_body, type: :scope

  sort_on :title, type: :string
  sort_on :priority, type: :int

  before_action :render_filter_errors, unless: :filters_valid?

  def index
    render json: filtrate(Post.all)
  end

  private

  def render_filter_errors
    render json: { errors: filter_errors }, status: :bad_request
  end
end
```

Consumers can then filter and sort via query parameters:

```
GET /posts?filters[title]=hello&filters[priority]=1...5&sort=-published_at,title
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'procore-sift'
```

And then execute:

```bash
$ bundle
```

## Documentation

- [Filters](docs/filters.md) - Filter types, scopes, ranges, JSONB, defaults, validation
- [Sorts](docs/sorts.md) - Sort types and scope-based sorting
- [Consumer API](docs/api.md) - Query parameter format for API consumers
- [Contributing](docs/contributing.md) - Development setup and publishing

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for release notes.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## About Procore

<img
  src="https://www.procore.com/images/procore_logo.png"
  alt="Procore Logo"
  width="250px"
/>

The Procore Gem is maintained by Procore Technologies.

Procore - building the software that builds the world.

Learn more about the #1 most widely used construction management software at [procore.com](https://www.procore.com/)
