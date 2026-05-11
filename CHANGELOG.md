## Unreleased

## 1.0.0

- Bump version to 1.0.0, making it an official release
- Change dependencies to only include `activerecord` as a direct dependency instead of the whole Rails framework
### Breaking changes:
- Bump required Ruby version to 2.7
- Drop support for Rails/ActiveRecord 4 and 5
- Require `activerecord >= 6.1`

## 0.17.0

- Add support for Rails 7.0

## 0.16.0

- Adds a `tap` method to `filter_on` to support mutating filter values

## 0.15.0

- Support for `null` filtering by `jsonb` type

## 0.14.0

- Add support for `jsonb` type (only for PostgreSQL)

## 0.13.0

## 0.12.0

- Change gem name to procore-sift

## 0.11.0

- Rename gem to Sift
- Add normalization and validation for date range values
- Tightened up ValueParser by privatizing unnecessarily public attr_accessors

## 0.10.0

- Support for integer filtering of JSON arrays

## 0.9.2 (January 26, 2018)

- Rename gem to Brita
- Publish to RubyGems
