module Xronor
  class DSL
    class ScheduleConverter
      KEYWORDS = %i(yearly annually monthly weekly daily hourly)
      WEEKDAYS = %i(sunday monday tuesday wednesday thursday friday saturday)

      class << self
        def convert(frequency, options)
          self.new(frequency, options).convert
        end
      end

      def initialize(frequency, options)
        @frequency = frequency
        @options = options
      end

      def convert
        cron_at, dow_diff = parse_and_convert_time

        case @frequency
        when *WEEKDAYS
          dow = WEEKDAYS.index(@frequency)
          dow += dow_diff

          case dow
          when -1 # Sunday -> Saturday
            dow = 6
          when 7  # Saturday -> Sunday
            dow = 0
          end

          [
            cron_at.min,
            cron_at.hour,
            "*",
            "*",
            dow,
          ].join(" ")
        when :day
          [
            cron_at.min,
            cron_at.hour,
            "*",
            "*",
            "*",
          ].join(" ")
        end
      end

      private

      def parse_and_convert_time
        original_time_class = Chronic.time_class
        Time.zone = @options[:timezone]
        Chronic.time_class = Time.zone
        local_at = Chronic.parse(@options[:at])
        cron_at = local_at.in_time_zone(@options[:cron_timezone])
        Chronic.time_class = original_time_class

        return cron_at, (cron_at.wday - local_at.wday)
      end
    end
  end
end
