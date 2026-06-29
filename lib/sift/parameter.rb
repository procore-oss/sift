module Sift
  # Value Object that wraps some handling of filter params
  class Parameter
    attr_reader :param, :type, :internal_name, :allow_nil

    def initialize(param, type, internal_name = param, allow_nil: false)
      @param = param
      @type = type
      @internal_name = internal_name
      @allow_nil = allow_nil
    end

    def parse_options
      {
        supports_boolean: supports_boolean?,
        supports_ranges: supports_ranges?,
        supports_json: supports_json?,
        supports_json_object: supports_json_object?
      }
    end

    def handler
      if type == :scope
        ScopeHandler.new(self)
      else
        WhereHandler.new(self)
      end
    end

    private

    def supports_ranges?
      ![:string, :text, :scope].include?(type)
    end

    def supports_json?
      [:int, :jsonb].include?(type)
    end

    def supports_json_object?
      type == :jsonb
    end

    def supports_boolean?
      type == :boolean
    end
  end
end
