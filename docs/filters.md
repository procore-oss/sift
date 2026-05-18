# Filters

## Filter Types

Every filter must have a type, so that Sift knows what to do with it. The current valid filter types are:

- int - Filter on an integer column
- decimal - Filter on a decimal column
- boolean - Filter on a boolean column
- string - Filter on a string column
- text - Filter on a text column
- date - Filter on a date column
- time - Filter on a time column
- datetime - Filter on a datetime column
- scope - Filter on an ActiveRecord scope
- jsonb - Filter on a jsonb column (PostgreSQL only)

## Filter on Scopes

Just as your filter values are used to scope queries on a column, values you
pass to a scope filter will be used as arguments to that scope. For example:

```ruby
class Post < ActiveRecord::Base
  scope :with_body, ->(text) { where(body: text) }
end

class PostsController < ApplicationController
  include Sift

  filter_on :with_body, type: :scope

  def index
    render json: filtrate(Post.all)
  end
end
```

Passing `?filters[with_body]=my_text` will call the `with_body` scope with
`my_text` as the argument.

Scopes that accept no arguments are currently not supported.

### Accessing Params with Filter Scopes

Filters with `type: :scope` have access to the params hash by passing in the desired keys to the `scope_params`. The keys passed in will be returned as a hash with their associated values.

```ruby
class Post < ActiveRecord::Base
  scope :user_posts_on_date, ->(date, options) {
    where(user_id: options[:user_id], blog_id: options[:blog_id], date: date)
  }
end

class UsersController < ApplicationController
  include Sift

  filter_on :user_posts_on_date, type: :scope, scope_params: [:user_id, :blog_id]

  def show
    render json: filtrate(Post.all)
  end
end
```

Passing `?filters[user_posts_on_date]=10/12/20` will call the `user_posts_on_date` scope with
`10/12/20` as the the first argument, and will grab the `user_id` and `blog_id` out of the params and pass them as a hash, as the second argument.

## Renaming Filter Params

A filter param can have a different field name than the column or scope. Use `internal_name` with the correct name of the column or scope.

```ruby
class PostsController < ApplicationController
  include Sift

  filter_on :post_id, type: :int, internal_name: :id
end
```

## Filter on Ranges

Some parameter types support ranges. Ranges are expected to be a string with the bounding values separated by `...`

For example `?filters[price]=3...50` would return records with a price between 3 and 50.

The following types support ranges:

- int
- decimal
- boolean
- date
- time
- datetime

## Mutating Filters

Filters can be mutated before the filter is applied using the `tap` argument. This is useful, for example, if you need to adjust the time zone of a `datetime` range filter.

```ruby
class PostsController < ApplicationController
  include Sift

  filter_on :expiration, type: :datetime, tap: ->(value, params) {
    value.split("...").
      map do |str|
        str.to_date.in_time_zone(LOCAL_TIME_ZONE)
      end.
      join("...")
  }
end
```

## Filter Defaults

You can specify a default behavior for a filter when no value is provided by the consumer. The `default` option takes a lambda that receives the collection and should return the modified collection:

```ruby
class PostsController < ApplicationController
  include Sift

  filter_on :status, type: :scope, default: ->(collection) { collection.where(status: 'active') }

  def index
    render json: filtrate(Post.all)
  end
end
```

If no `?filters[status]=...` parameter is passed, the default lambda will be applied automatically.

## Custom Validation

You can add custom validation logic to a filter using the `validate` option. This allows you to implement validation rules beyond the built-in type checking:

```ruby
class PostsController < ApplicationController
  include Sift

  filter_on :id_array, type: :int, internal_name: :id, validate: ->(validator) {
    value = validator.instance_variable_get("@id_array")
    if value.is_a?(Array)
      unless value.all? { |v| Integer(v) rescue false }
        validator.errors.add(:id_array, "All values must be valid integers")
      end
    end
  }

  def index
    render json: filtrate(Post.all)
  end
end
```

The lambda receives the validator object, which gives you access to the filter value and allows you to add errors using `validator.errors.add(:field_name, "error message")`.

## Filter on JSONB Column

Usually JSONB columns stores values as an Array or an Object (key-value), in both cases the parameter needs to be sent in a JSON format.

**Array**

It should be sent an array in the URL Query parameters:

- `?filters[metadata]=[1,2]`

**Key-value**

It can be passed one or more key values:

- `?filters[metadata]={"data_1":"test"}`
- `?filters[metadata]={"data_1":"test","data_2":"[1,2]"}`

When the value is an array, it will filter records with those values or more, for example:

- `?filters[metadata]={"data_2":"[1,2]"}`

Will return records with next values stored in the JSONB column `metadata`:

```ruby
{ data_2: 1 }
{ data_2: 2 }
{ data_2: [1] }
{ data_2: [2] }
{ data_2: [1,2] }
{ data_2: [1,2,3] }
```

When the `null` value is included in the array, it will return also all the records without any value in that property, for example:

- `?filters[metadata]={"data_2":"[false,null]"}`

Will return records with next values stored in the JSONB column `metadata`:

```ruby
{ data_2: null }
{ data_2: false }
{ data_2: [false] }
{ data_1: {another: 'information'} } # When the JSONB key "data_2" is not set.
```

## Filter on JSON Array

`int` type filters support sending the values as an array in the URL Query parameters. For example `?filters[id]=[1,2]`. This is a way to keep payloads smaller for GET requests. When URI encoded this will become `filters%5Bid%5D=%5B1,2%5D` which is much smaller the standard format of `filters%5Bid%5D%5B%5D=1&&filters%5Bid%5D%5B%5D=2`.

On the server side, the params will be received as:

```ruby
# JSON array encoded result
"filters"=>{"id"=>"[1,2]"}

# standard array format
"filters"=>{"id"=>["1", "2"]}
```

Note that this feature cannot currently be wrapped in an array and should not be used in combination with sending array parameters individually.

- `?filters[id][]=[1,2]` => invalid
- `?filters[id][]=[1,2]&filters[id][]=3` => invalid
- `?filters[id]=[1,2]&filters[id]=3` => valid but only 3 is passed through to the server
- `?filters[id]=[1,2]` => valid

### A Note on Encoding for JSON Array Feature

JSON arrays contain the reserved characters "`,`" and "`[`" and "`]`". When encoding a JSON array in the URL there are two different ways to handle the encoding. Both ways are supported by Rails.
For example, lets look at the following filter with a JSON array `?filters[id]=[1,2]`:

- `?filters%5Bid%5D=%5B1,2%5D`
- `?filters%5Bid%5D%3D%5B1%2C2%5D`

In both cases Rails will correctly decode to the expected result of

```ruby
{ "filters" => { "id" => "[1,2]" } }
```
