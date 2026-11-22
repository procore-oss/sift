module Sift
  # TypeValidator validates that the incoming param is of the specified type
  class TypeValidator
    DATETIME_RANGE_PATTERN = { format: { with: /\A.+(?:[^.]\.\.\.[^.]).+\z/, message: "must be a range" }, valid_date_range: true }.freeze
    DECIMAL_PATTERN = { numericality: true, allow_nil: true }.freeze
    BOOLEAN_PATTERN = { inclusion: { in: [true, false] }, allow_nil: true }.freeze
    JSON_PATTERN = { valid_json: true }.freeze

    WHITELIST_TYPES = [:int,
                       :decimal,
                       :boolean,
                       :string,
                       :text,
                       :date,
                       :time,
                       :datetime,
                       :scope,
                       :jsonb].freeze

    def initialize(param, type, allow_nil: false, allow_array_range: false)
      @param = param
      @type = type
      @allow_nil = allow_nil
      @allow_array_range = allow_array_range
    end

    attr_reader :param, :type

    def validate
      case type
      when :datetime, :date, :time
        @allow_array_range ? date_range_or_array_range : DATETIME_RANGE_PATTERN
      when :int
        valid_int?
      when :decimal
        DECIMAL_PATTERN
      when :boolean
        BOOLEAN_PATTERN
      when :jsonb
        JSON_PATTERN
      end
    end

    def valid_type?
      WHITELIST_TYPES.include?(type)
    end

    private

    def valid_int?
      @allow_nil ? { valid_int: { allow_null_token: true } } : { valid_int: true }
    end

    def date_range_or_array_range
      field = param
      array_value = ->(record) { record.public_send(field).is_a?(Array) }
      {
        allow_blank: true,
        format: DATETIME_RANGE_PATTERN[:format].merge(unless: array_value),
        valid_date_range: { unless: array_value },
        valid_date_array_range: { if: array_value }
      }
    end
  end
end
