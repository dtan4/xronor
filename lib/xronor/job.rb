module Xronor
  class Job
    DOM_INDEX = 2
    DOW_INDEX = 4

    class << self
      def from_crontab(cron, command, prefix, regexp)
        name = name_from_command(command, prefix, regexp)
        schedule = cloud_watch_schedule(cron)

        self.new(name, schedule, command)
      end

      private

      def cloud_watch_schedule(cron)
        cron_fields = cron.split(" ")
        cron_fields[DOW_INDEX] = "?" if cron_fields[DOM_INDEX] == "*" && cron_fields[DOW_INDEX] == "*"
        cron_fields << "*" # Year
        "cron(#{cron_fields.join(" ")})"
      end

      def name_from_command(command, prefix, regexp)
        matched = Regexp.new(regexp).match(command)
        "#{prefix}#{matched ? matched[1] : ""}"
      end
    end

    def initialize(name, schedule, command)
      @name = name
      @schedule = schedule
      @command = command
    end

    def command
      @command
    end

    def rule_name
      "#{@name}-#{hashcode}"
    end

    def name
      @name
    end

    def schedule
      @schedule
    end

    private

    def hashcode
      OpenSSL::Digest::SHA256.hexdigest("#{@name}\t#{@schedule}\t#{@command}")[0..12]
    end
  end
end
