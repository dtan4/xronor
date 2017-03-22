module Xronor
  class DSL
    class Default
      DEFAULT_TIMEZONE = "UTC"

      def initialize(&block)
        @result = OpenStruct.new(
          cron_timezone: DEFAULT_TIMEZONE,
          prefix: "",
          timezone: DEFAULT_TIMEZONE,
        )

        instance_eval(&block)
      end

      %i(cron_timezone prefix timezone).each do |key|
        define_method(key) do |arg|
          @result.send("#{key}=", arg)
        end
      end

      def result
        @result
      end
    end
  end
end
