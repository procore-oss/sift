require "test_helper"

class ParameterTest < ActiveSupport::TestCase
  test "key_type resolves from a Hash with symbol keys" do
    parameter = Sift::Parameter.new(:metadata, :jsonb, :metadata, { price: :decimal })

    assert_equal :decimal, parameter.key_type("price")
    assert_equal :decimal, parameter.key_type(:price)
  end

  test "key_type resolves from a callable" do
    parameter = Sift::Parameter.new(:custom_fields, :jsonb, :custom_fields, ->(key) {
      key == "123" ? :date : nil
    })

    assert_equal :date, parameter.key_type("123")
    assert_nil parameter.key_type("456")
  end

  test "key_type is nil when no keys are declared" do
    parameter = Sift::Parameter.new(:metadata, :jsonb)

    assert_nil parameter.key_type("price")
  end

  test "range_key? reflects whether a key has a declared type" do
    parameter = Sift::Parameter.new(:metadata, :jsonb, :metadata, { price: :decimal })

    assert parameter.range_key?("price")
    refute parameter.range_key?("color")
  end
end
