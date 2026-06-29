module Sift
  class ValueParser
    def initialize(value:, type: nil, options: {})
      @value = value
      @supports_boolean = options.fetch(:supports_boolean, false)
      @supports_ranges = options.fetch(:supports_ranges, false)
      @supports_json = options.fetch(:supports_json, false)
      @supports_json_object = options.fetch(:supports_json_object, false)
      @value = normalized_value(value, type)
    end

    def parse
      @_result ||=
        if parse_as_range?
          range_value
        elsif parse_as_boolean?
          boolean_value
        elsif parse_as_json?
          supports_json_object ? parse_json_and_values : array_from_json
        else
          value
        end
    end

    def parse_json(string)
      JSON.parse(string)
    rescue JSON::ParserError
      string
    end

    def parse_json_and_values
      parsed_jsonb = parse_json(value)
      return parsed_jsonb if parsed_jsonb.is_a?(Array) || parsed_jsonb.is_a?(String)

      parsed_jsonb.each_with_object({}) do |key_value, hash|
        key   = key_value.first
        value = key_value.last
        hash[key] = parse_jsonb_value(value)
      end
    end

    def array_from_json
      result = parse_json(value)
      if result.is_a?(Array)
        result
      else
        value
      end
    end

    private

    attr_reader :value, :type, :supports_boolean, :supports_json, :supports_json_object, :supports_ranges

    def parse_as_range?(raw_value=value)
      # jsonb values must not be parsed as a top-level range: the outer value is
      # a Hash (nested params) or a JSON object string, and any "..." range lives
      # inside an individual key's value, which is handled by parse_jsonb_value.
      return false if raw_value.is_a?(Hash) || supports_json_object

      supports_ranges && raw_value.to_s.include?("...")
    end

    # Parses a single value from a jsonb object. A "..." string is converted into
    # a Range (with its endpoints normalized to DateTimes where possible) so the
    # range handling lives here rather than in WhereHandler; other strings may be
    # nested JSON (e.g. an embedded array) and are parsed accordingly.
    def parse_jsonb_value(raw_value)
      return raw_value unless raw_value.is_a?(String)
      return date_range(raw_value) if raw_value.include?("...")

      parse_json(raw_value)
    end

    def range_value
      Range.new(*value.split("..."))
    end

    def parse_as_json?
      supports_json && value.is_a?(String)
    end

    def parse_as_boolean?
      supports_boolean
    end

    def boolean_value
      ActiveRecord::Type::Boolean.new.cast(value)
    end

    def normalized_value(raw_value, type)
      if type == :datetime && parse_as_range?(raw_value)
        normalized_date_range(raw_value)
      else
        raw_value
      end
    end

    def normalized_date_range(raw_value)
      from_date_string, end_date_string = raw_value.split("...")
      return unless end_date_string

      [from_date_string, end_date_string].map { |date_string| parse_date(date_string) }.join("...")
    end

    def date_range(raw_value)
      from_date_string, end_date_string = raw_value.split("...")
      Range.new(parse_date(from_date_string), parse_date(end_date_string))
    end

    def parse_date(date_string)
      DateTime.parse(date_string.to_s)
    rescue StandardError
      date_string
    end
  end
end
