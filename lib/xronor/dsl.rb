module Xronor
  class DSL
    class << self
      def eval(body)
        self.new(body)
      end
    end

    def initialize(body)
      @result = OpenStruct.new(
        jobs: [],
        options: {},
      )

      instance_eval(body)
    end

    def every(frequency, options = {}, &block)
      @result.jobs << Xronor::DSL::Job.new(frequency, options.merge(@result.options), &block).result
    end

    def result
      @result
    end
  end
end
