module Xronor
  class DSL
    class Job
      include Xronor::DSL::Checker

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
        required(:name, @result.name)
        @result
      end
    end
  end
end
