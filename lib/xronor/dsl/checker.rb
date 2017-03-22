module Xronor
  class DSL
    module Checker
      class ValidationError < StandardError
      end

      def required(name, value)
        invalid = false

        if value
          case value
          when String
            invalid = value.strip.empty?
          when Array, Hash
            invalid = value.empty?
          end
        else
          invalid = true
        end

        raise ValidationError.new("'#{name}' is required") if invalid
      end
    end
  end
end
