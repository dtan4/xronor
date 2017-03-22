module Xronor
  class DSL
    DEFAULT_PREFIX = "scheduler-"
    DEFAULT_TIMEZONE = "UTC"
    DEFAULT_CRON_TIMEZONE = "UTC"

    class << self
      def eval(body)
        self.new(body)
      end

      def seconds(number, units)
        Xronor::DSL::NumericSeconds.seconds(number, units)
      end
    end

    def initialize(body)
      @result = OpenStruct.new(
        jobs: [],
        options: {
          prefix: DEFAULT_PREFIX,
          timezone: DEFAULT_TIMEZONE,
          cron_timezone: DEFAULT_CRON_TIMEZONE,
        },
      )

      instance_eval(body)
    end

    def default(&block)
      @result.options.merge!(Xronor::DSL::Default.new(&block).result.to_h)
    end

    def every(frequency, options = {}, &block)
      @result.jobs << Xronor::DSL::Job.new(frequency, options.merge(@result.options), &block).result
    end

    def result
      @result
    end
  end
end
