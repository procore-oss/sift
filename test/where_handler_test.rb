require "test_helper"

class WhereHandlerTest < ActiveSupport::TestCase
  test "it filters jsonb arrays with the full value" do
    param = Sift::Parameter.new(:metadata, :jsonb)
    collection = Minitest::Mock.new
    filtered_collection = Object.new
    collection.expect :where, filtered_collection, ["metadata @> ?", "[1, 2]"]

    result = Sift::WhereHandler.new(param).call(collection, [1, 2], {}, [])

    assert_same filtered_collection, result
    assert_mock collection
  end

  test "it filters jsonb key ranges with a type-driven cast and bound params" do
    param = Sift::Parameter.new(:metadata, :jsonb, :metadata, { price: :decimal })
    collection = Minitest::Mock.new
    filtered_collection = Object.new
    collection.expect(
      :where,
      filtered_collection,
      ["(metadata->>'price')::numeric BETWEEN ? AND ?", "10", "100"]
    )

    result = Sift::WhereHandler.new(param).call(collection, { "price" => Range.new("10", "100") }, {}, [])

    assert_same filtered_collection, result
    assert_mock collection
  end

  test "it maps each declared key type to the correct Postgres cast" do
    casts = {
      int: "::integer",
      decimal: "::numeric",
      date: "::date",
      datetime: "::timestamptz",
      time: "::time"
    }

    casts.each do |key_type, cast|
      param = Sift::Parameter.new(:metadata, :jsonb, :metadata, { value: key_type })
      collection = Minitest::Mock.new
      filtered_collection = Object.new
      collection.expect(
        :where,
        filtered_collection,
        ["(metadata->>'value')#{cast} BETWEEN ? AND ?", "a", "b"]
      )

      result = Sift::WhereHandler.new(param).call(collection, { "value" => Range.new("a", "b") }, {}, [])

      assert_same filtered_collection, result
      assert_mock collection
    end
  end
end
