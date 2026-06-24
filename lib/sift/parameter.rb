module Sift
  # Value Object that wraps some handling of filter params
  class Parameter
    attr_reader :param, :type, :internal_name, :keys

    def initialize(param, type, internal_name = param, keys = nil)
      @param = param
      @type = type
      @internal_name = internal_name
      @keys = keys
    end

    # Resolves the declared cast type for a JSONB key, supporting both a Hash
    # (`{ price: :decimal }`) and a callable (`->(key) { ... }`) that is
    # evaluated per request. Returns nil when no type is declared for the key.
    def key_type(key)
      return nil if keys.nil?

      if keys.respond_to?(:call)
        keys.call(key)
      else
        keys[key.to_sym] || keys[key.to_s]
      end
    end

    def range_key?(key)
      !key_type(key).nil?
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
