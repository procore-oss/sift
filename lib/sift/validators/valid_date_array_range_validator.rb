class ValidDateArrayRangeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    from_date, end_date, *extra_bounds = value

    if from_date.blank? || extra_bounds.any?
      record.errors.add attribute, "must be a range"
    elsif ![from_date, end_date].compact_blank.all? { |date| valid_date?(date) }
      record.errors.add attribute, "is invalid"
    end
  end

  private

  def valid_date?(date)
    date.respond_to?(:to_date) && !date.to_date.nil?
  rescue ArgumentError, RangeError
    false
  end
end
