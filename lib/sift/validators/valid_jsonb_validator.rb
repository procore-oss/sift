# Validates JSONB filter values that use the per-key range form
# (`{"price":"10...100"}`). JSON validity itself is handled by ValidJsonValidator;
# this validator only inspects keys whose string value contains "..." and
# ensures that the key has a declared, range-capable type and that both bounds
# cast to that type. This prevents broken SQL from reaching the database.
class ValidJsonbValidator < ActiveModel::EachValidator
  SUPPORTED_RANGE_TYPES = [:int, :decimal, :date, :datetime, :time].freeze

  def validate_each(record, attribute, value)
    parsed = parse_json(value)
    return unless parsed.is_a?(Hash)

    parsed.each do |key, key_value|
      next unless key_value.is_a?(String) && key_value.include?("...")

      key_type = resolve_key_type(key)

      if key_type.nil? || !SUPPORTED_RANGE_TYPES.include?(key_type)
        record.errors.add(attribute, "range filtering on key '#{key}' requires a declared key type")
        next
      end

      validate_bounds(record, attribute, key, key_value, key_type)
    end
  end

  private

  def parse_json(value)
    value = value.strip if value.is_a?(String)
    JSON.parse(value)
  rescue JSON::ParserError, TypeError
    nil
  end

  def resolve_key_type(key)
    declared = options[:keys]
    return nil if declared.nil?

    if declared.respond_to?(:call)
      declared.call(key)
    else
      declared[key.to_sym] || declared[key.to_s]
    end
  end

  def validate_bounds(record, attribute, key, key_value, key_type)
    bounds = key_value.split("...")

    bounds.each do |bound|
      next if valid_bound?(bound, key_type)

      record.errors.add(attribute, "range bound '#{bound}' for key '#{key}' is not a valid #{key_type}")
    end
  end

  def valid_bound?(bound, key_type)
    value = bound.to_s.strip

    case key_type
    when :int
      !!(/\A-?\d+\z/ =~ value)
    when :decimal
      !!Float(value)
    when :date, :datetime
      !!DateTime.parse(value)
    when :time
      !!Time.parse(value)
    else
      false
    end
  rescue ArgumentError, TypeError
    false
  end
end
