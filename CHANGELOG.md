## Unreleased

- `allow_nil: true` filters now accept a bare JSON `null` element in an array (`[null,"5"]`, `[null]`) as `IS NULL`, the same as the string `"null"`. Previously these requests failed validation with a 400. Blank values (`nil` / `""` / `[]`) are still never treated as `null`.
- Fix `[null]` alone being rejected by `int` validation because `[nil].any?` is `false`.

## 1.2.1

- Fix: a blank filter value (`nil` / `""` / `[]`) no longer activates its filter. 1.2.0 activated a filter whenever its param key was present, so an empty value produced conditions like `WHERE col = ''` — harmless on some string columns, but a 500 (`PG::InvalidTextRepresentation`) on integer/uuid columns and unintended narrowing (`WHERE col IN ()`) elsewhere. Blank values are now skipped again (pre-1.2 behavior). A literal boolean `false` is still treated as an active value, preserving the #58 fix.

## 1.2.0

### Breaking changes:
- Drop support for Ruby 2.7, 3.0, 3.1, and 3.2 (all end-of-life); require Ruby `>= 3.3`
- Drop support for Rails 7.0 and 7.1 (end-of-life); require `activerecord >= 7.2`
- CI test matrix now covers Ruby 3.3–3.4 against Rails 7.2 and 8.0

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
