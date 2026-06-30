## Unreleased

## 1.1.0

- Add support for Rails 7.1, 7.2, and 8.0 (#67)
- Migrate CI from Travis to GitHub Actions; test matrix covers Ruby 2.7–3.3 against Rails 7.0–8.0 (#67)
- Add `allow_nil: true` option to `filter_on` to enable `IS NULL` filtering for non-JSONB column types (#84)
- Add support for date range filtering on JSONB keys, using the same `...` range format as other filters (#83)
- Fix boolean filter being silently skipped when the value is `false` (#58). Note: filters with empty-string values are now applied (previously skipped); review consumers if you relied on the old behavior.
- Fix `NameError` in JSONB filtering when value is an Array (#56)
- Reorganize documentation into a `docs/` directory (#68)

### Breaking changes:
- Drop support for Rails 6.1 / ActiveRecord 6.1
- Require `activerecord >= 7.0`

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
