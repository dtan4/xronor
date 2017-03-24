module Xronor
  class DSL
    DEFAULT_PREFIX = "scheduler-"
    DEFAULT_TIMEZONE = "UTC"
    DEFAULT_CRON_TIMEZONE = "UTC"
    DEFAULT_JOB_TEMPLATE = ":job"

    class DuplicatedError < StandardError; end

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
        jobs: {},
        options: {
          prefix: DEFAULT_PREFIX,
          timezone: DEFAULT_TIMEZONE,
          cron_timezone: DEFAULT_CRON_TIMEZONE,
          job_template: DEFAULT_JOB_TEMPLATE,
        },
      )

      instance_eval(body)
    end

    def default(&block)
      @result.options.merge!(Xronor::DSL::Default.new(&block).result.to_h)
    end

    def every(frequency, options = {}, &block)
      job = Xronor::DSL::Job.new(frequency, @result.options.merge(options), &block).result
      @result.jobs[job.name] = job
    end

    def job_template(template)
      @result.options[:job_template] = template
    end

    def job_type(name, template)
      Xronor::DSL::Job.class_eval do
        define_method(name) do |task, *args|
          options = { task: task }
          options.merge!(args[0]) if args[0].is_a? Hash
          job = process_template(template, options)
          @result.command = process_template(@options[:job_template], options.merge({ job: job }))
        end
      end
    end

    def result
      @result
    end
  end
end
