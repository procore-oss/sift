module Sift
  class WhereHandler
    JSONB_RANGE_CASTS = {
      int: "::integer",
      decimal: "::numeric",
      date: "::date",
      datetime: "::timestamptz",
      time: "::time"
    }.freeze

    def initialize(param)
      @param = param
    end

    def call(collection, value, _params, _scope_params)
      if @param.type == :jsonb
        apply_jsonb_conditions(collection, value)
      else
        collection.where(@param.internal_name => value)
      end
    end

    private

    def apply_jsonb_conditions(collection, value)
      return collection.where("#{@param.internal_name} @> ?", value.to_s) if value.is_a?(Array)

      value.each do |key, val|
        collection = if val.is_a?(Range)
          apply_jsonb_range(collection, key, val)
        elsif val.is_a?(Array)
          apply_jsonb_array(collection, key, val)
        else
          collection.where("#{@param.internal_name}->>'#{key}' = ?", val.to_s)
        end
      end
      collection
    end

    def apply_jsonb_array(collection, key, val)
      elements = Hash[val.each_with_index.map { |item, i| ["value_#{i}".to_sym, item.to_s] }]
      elements[:all_values] = val.compact.map(&:to_s)
      main_condition = "('{' || TRANSLATE(#{@param.internal_name}->>'#{key}', '[]','') || '}')::text[] && ARRAY[:all_values]"
      sub_conditions = val.each_with_index.map do |element, i|
        "#{@param.internal_name}->>'#{key}' #{element.nil? ? 'IS NULL' : "= :value_#{i}"}"
      end.join(" OR ")
      collection.where("(#{main_condition}) OR (#{sub_conditions})", elements)
    end

    def apply_jsonb_range(collection, key, range)
      key_type = @param.key_type(key)
      cast = JSONB_RANGE_CASTS.fetch(key_type) do
        raise ArgumentError, "range filtering on JSONB key '#{key}' requires a declared key type"
      end

      condition = "(#{@param.internal_name}->>'#{quote_jsonb_key(key)}')#{cast} BETWEEN ? AND ?"
      collection.where(condition, range.begin, range.end)
    end

    # Escapes a JSONB key for safe interpolation inside a single-quoted SQL
    # string literal. Bounds are always passed as bind parameters.
    def quote_jsonb_key(key)
      key.to_s.gsub("'", "''")
    end
  end
end
