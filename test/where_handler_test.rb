require "test_helper"

class WhereHandlerTest < ActiveSupport::TestCase
  test "for non-jsonb params it builds a simple equality where clause" do
    parameter = Sift::Parameter.new(:title, :string, :title)
    handler = Sift::WhereHandler.new(parameter)

    relation = handler.call(Post.all, "hello", {}, [])

    assert_includes relation.to_sql, %("posts"."title" = 'hello')
  end

  test "for non-jsonb params it builds a BETWEEN clause for ranges" do
    parameter = Sift::Parameter.new(:published_at, :datetime, :published_at)
    handler = Sift::WhereHandler.new(parameter)

    range = Range.new("2018-01-01T00:00:00+00:00", "2018-01-02T00:00:00+00:00")
    relation = handler.call(Post.all, range, {}, [])

    assert_includes relation.to_sql, "BETWEEN"
  end

  test "for jsonb params with a hash it builds a key-value equality clause" do
    parameter = Sift::Parameter.new(:metadata, :jsonb, :metadata)
    handler = Sift::WhereHandler.new(parameter)

    relation = handler.call(Post.all, { "a" => 4 }, {}, [])

    assert_includes relation.to_sql, "metadata->>'a' = '4'"
  end

  test "for jsonb params with an array of values it builds an IN-style clause" do
    parameter = Sift::Parameter.new(:metadata, :jsonb, :metadata)
    handler = Sift::WhereHandler.new(parameter)

    relation = handler.call(Post.all, { "tags" => ["red", "blue"] }, {}, [])
    sql = relation.to_sql

    assert_includes sql, "metadata->>'tags'"
    assert_includes sql, "ARRAY"
    assert_includes sql, "'red'"
    assert_includes sql, "'blue'"
  end

  test "for jsonb params with a Range value it builds a BETWEEN clause from the endpoints" do
    parameter = Sift::Parameter.new(:metadata, :jsonb, :metadata)
    handler = Sift::WhereHandler.new(parameter)

    range = Range.new(DateTime.parse("2018-01-01T00:00:00+00:00"), DateTime.parse("2018-01-02T00:00:00+00:00"))
    relation = handler.call(Post.all, { "published_at" => range }, {}, [])
    sql = relation.to_sql

    assert_includes sql, "metadata->>'published_at' BETWEEN"
    assert_match(/BETWEEN '2018-01-01[T ]00:00:00.*' AND '2018-01-02[T ]00:00:00.*'/, sql)
  end

  test "for jsonb params with a Range of raw strings it binds the endpoints verbatim" do
    parameter = Sift::Parameter.new(:metadata, :jsonb, :metadata)
    handler = Sift::WhereHandler.new(parameter)

    relation = handler.call(Post.all, { "window" => Range.new("not-a-date", "also-not-a-date") }, {}, [])
    sql = relation.to_sql

    assert_includes sql, "metadata->>'window' BETWEEN"
    assert_includes sql, "'not-a-date'"
    assert_includes sql, "'also-not-a-date'"
  end

  test "for jsonb params it does not treat plain strings as date ranges" do
    parameter = Sift::Parameter.new(:metadata, :jsonb, :metadata)
    handler = Sift::WhereHandler.new(parameter)

    relation = handler.call(Post.all, { "label" => "anything" }, {}, [])
    sql = relation.to_sql

    assert_includes sql, "metadata->>'label' = 'anything'"
    refute_includes sql, "BETWEEN"
  end

  test "for jsonb params with multiple keys it ANDs date ranges with equality conditions" do
    parameter = Sift::Parameter.new(:metadata, :jsonb, :metadata)
    handler = Sift::WhereHandler.new(parameter)

    range = Range.new(DateTime.parse("2018-01-01T00:00:00+00:00"), DateTime.parse("2018-01-02T00:00:00+00:00"))
    relation = handler.call(
      Post.all,
      { "published_at" => range, "status" => "active" },
      {},
      []
    )
    sql = relation.to_sql

    assert_includes sql, "metadata->>'published_at' BETWEEN"
    assert_includes sql, "metadata->>'status' = 'active'"
  end

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
