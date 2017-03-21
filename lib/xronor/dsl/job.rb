module Xronor
  class DSL
    class Job
      def initialize(frequency, options, &block)
        @frequency = frequency
        @options = options
        @result = OpenStruct.new(
          description: "",
          name: "",
        )

        instance_eval(&block)
      end

      def description(value)
        @result.description = value
      end

      def name(value)
        @result.name = value
      end

      def result
        @result
      end
    end
  end
end
