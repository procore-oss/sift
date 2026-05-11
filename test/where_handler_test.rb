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
end
