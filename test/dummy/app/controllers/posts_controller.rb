class PostsController < ApplicationController
  include Sift

  LOCAL_TIME_ZONE = "America/New_York"

  filter_on :id, type: :int
  filter_on :priority, type: :int
  filter_on :rating, type: :decimal
  filter_on :visible, type: :boolean
  filter_on :title, type: :string
  filter_on :body, type: :text
  filter_on :expiration, type: :date
  filter_on :hidden_after, type: :time
  filter_on :published_at, type: :datetime
  filter_on :expired_before, type: :scope
  filter_on :expired_before_and_priority, type: :scope, scope_params: [:priority]
  filter_on :metadata, type: :jsonb

  filter_on :french_bread, type: :string, internal_name: :title
  filter_on :body2, type: :scope, internal_name: :body2, default: ->(c) { c.order(:body) }

  filter_on :expiration, type: :datetime, tap: ->(value, params) {
    value.split("...").
      map do |str|
        str.to_date.in_time_zone(LOCAL_TIME_ZONE)
      end.
      join("...")
  }

  # rubocop:disable Style/RescueModifier
  filter_on :id_array, type: :int, internal_name: :id, validate: ->(validator) {
    value = validator.instance_variable_get("@id_array")
    if value.is_a?(Array)
      # Verify all variables in the array are integers
      unless value.all? { |v| (Integer(v) rescue false) }
        validator.errors.add(:id_array, "Not all values were valid integers")
      end
    elsif !(Integer(value) rescue false)
      validator.errors.add(:id_array, "It not an integer")
    end
  }
  # rubocop:enable Style/RescueModifier

  before_action :render_filter_errors, unless: :filters_valid?

  sort_on :visible, type: :int
  sort_on :title, type: :string
  sort_on :priority, type: :string
  sort_on :foobar, type: :string, internal_name: :title
  sort_on :dynamic_sort, type: :scope, internal_name: :expired_before_ordered_by_body, scope_params: [:date, :direction]

  def index
    render json: filtrate(Post.all)
  end

  private

  def render_filter_errors
    render json: { errors: filter_errors }, status: :bad_request and return
  end
end
