class ValidIntValidator < ActiveModel::EachValidator
  NULL_TOKEN = "null"

  def validate_each(record, attribute, value)
    record.errors.add attribute, (options[:message] || "must be integer, array of integers, or range") unless
      valid_int?(value)
  end

  private

  def allow_null_token?
    options.fetch(:allow_null_token, false)
  end

  def valid_int?(value)
    (allow_null_token? && null_token?(value)) || integer_array?(value) || integer_or_range?(value)
  end

  def integer_array?(value)
    if value.is_a?(String)
      value = Sift::ValueParser.new(value: value).array_from_json
    end

    value.is_a?(Array) && !value.empty? && value.all? { |v| integer_or_range?(v) || (allow_null_token? && null_element?(v)) }
  end

  # A nil element can only come from an explicit JSON null (e.g. `[null,"5"]`); Rails strips
  # nils from array params and blank values never reach here as array elements.
  def null_element?(value)
    value.nil? || null_token?(value)
  end

  def integer_or_range?(value)
    !!(/\A\d+(...\d+)?\z/ =~ value.to_s)
  end

  def null_token?(value)
    value.to_s.downcase == NULL_TOKEN
  end
end
