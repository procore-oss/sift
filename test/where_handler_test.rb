require "minitest/autorun"
require "sift/parameter"
require "sift/where_handler"

class WhereHandlerTest < Minitest::Test
  def test_it_filters_jsonb_arrays_with_the_full_value
    param = Sift::Parameter.new(:metadata, :jsonb)
    collection = Minitest::Mock.new
    filtered_collection = Object.new
    collection.expect :where, filtered_collection, ["metadata @> ?", "[1, 2]"]

    result = Sift::WhereHandler.new(param).call(collection, [1, 2], {}, [])

    assert_same filtered_collection, result
    assert_mock collection
  end
end
