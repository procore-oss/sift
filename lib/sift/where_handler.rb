module Sift
  class WhereHandler
    NULL_TOKEN = "null"

    def initialize(param)
      @param = param
    end

    def call(collection, value, _params, _scope_params)
      if @param.type == :jsonb
        apply_jsonb_conditions(collection, value)
      elsif @param.allow_nil
        apply_null_aware_conditions(collection, value)
      else
        collection.where(@param.internal_name => value)
      end
    end

    private

    def apply_null_aware_conditions(collection, value)
      values = Array(value)
      has_null = values.any? { |v| v.to_s.downcase == NULL_TOKEN }
      non_null_values = values.reject { |v| v.to_s.downcase == NULL_TOKEN }

      if has_null && non_null_values.any?
        collection.where(@param.internal_name => nil)
                  .or(collection.where(@param.internal_name => non_null_values))
      elsif has_null
        collection.where(@param.internal_name => nil)
      else
        collection.where(@param.internal_name => value)
      end
    end

    def apply_jsonb_conditions(collection, value)
      return collection.where("#{@param.internal_name} @> ?", value.to_s) if value.is_a?(Array)

      value.each do |key, val|
        collection = if val.is_a?(Array)
          elements = Hash[val.each_with_index.map { |item, i| ["value_#{i}".to_sym, item.to_s] } ]
          elements[:all_values] = val.compact.map(&:to_s)
          main_condition =  "('{' || TRANSLATE(#{@param.internal_name}->>'#{key}', '[]','') || '}')::text[] && ARRAY[:all_values]"
          sub_conditions = val.each_with_index.map do |element, i|
            "#{@param.internal_name}->>'#{key}' #{element === nil ? 'IS NULL' : "= :value_#{i}"}"
          end.join(' OR ')
          collection.where("(#{main_condition}) OR (#{sub_conditions})", elements)
        else
          collection.where("#{@param.internal_name}->>'#{key}' = ?", val.to_s)
        end
      end
      collection
    end
  end
end
