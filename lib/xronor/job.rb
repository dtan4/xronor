module Xronor
  class Job
    DOM_INDEX = 2
    DOW_INDEX = 4

    def initialize(name, description, schedule, command)
      @name = name
      @description = description
      @schedule = schedule
      @command = command
    end

    def cloud_watch_schedule
      cron_fields = @schedule.split(" ")
      cron_fields[DOW_INDEX] = "?" if cron_fields[DOM_INDEX] == "*" && cron_fields[DOW_INDEX] == "*"
      cron_fields << "*" # Year
      "cron(#{cron_fields.join(" ")})"
    end

    def cloud_watch_rule_name(prefix)
      "#{prefix}#{@name}-#{hashcode}"
    end

    def command
      @command
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
