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

      %i(description name).each do |key|
        define_method(key) do |arg|
          @result.send("#{key}=", arg)
        end
      end

      def result
        required(:name, @result.name)
        @result
      end
    end
  end
end
