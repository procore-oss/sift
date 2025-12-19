# Sorts

## Sort Types

Every sort must have a type, so that Sift knows what to do with it. The current valid sort types are:

- int - Sort on an integer column
- decimal - Sort on a decimal column
- string - Sort on a string column
- text - Sort on a text column
- date - Sort on a date column
- time - Sort on a time column
- datetime - Sort on a datetime column
- scope - Sort on an ActiveRecord scope

## Sort on Scopes

Just as your sort values are used to scope queries on a column, values you
pass to a scope sort will be used as arguments to that scope. For example:

```ruby
class Post < ActiveRecord::Base
  scope :order_on_body_no_params, -> { order(body: :asc) }
  scope :order_on_body, ->(direction) { order(body: direction) }
  scope :order_on_body_then_id, ->(body_direction, id_direction) { order(body: body_direction).order(id: id_direction) }
end

class PostsController < ApplicationController
  include Sift

  sort_on :order_by_body_ascending, internal_name: :order_on_body_no_params, type: :scope
  sort_on :order_by_body, internal_name: :order_on_body, type: :scope, scope_params: [:direction]
  sort_on :order_by_body_then_id, internal_name: :order_on_body_then_id, type: :scope, scope_params: [:direction, :asc]

  def index
    render json: filtrate(Post.all)
  end
end
```

`scope_params` takes an order-specific array of the scope's arguments. Passing in the param :direction allows the consumer to choose which direction to sort in (ex. `-order_by_body` will sort `:desc` while `order_by_body` will sort `:asc`)

Passing `?sort=-order_by_body` will call the `order_on_body` scope with
`:desc` as the argument. The direction is the only argument that the consumer has control over.

Passing `?sort=-order_by_body_then_id` will call the `order_on_body_then_id` scope where the `body_direction` is `:desc`, and the `id_direction` is `:asc`. Note: in this example the user has no control over id_direction.

To demonstrate: Passing `?sort=order_by_body_then_id` will call the `order_on_body_then_id` scope where the `body_direction` this time is `:asc`, but the `id_direction` remains `:asc`.

Scopes that accept no arguments are currently supported, but you should note that the user has no say in which direction it will sort on.

`scope_params` can also accept symbols that are keys in the `params` hash. The value will be fetched and passed on as an argument to the scope.
