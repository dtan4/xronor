module Wh2cwe
  class Job
    DOM_INDEX = 2
    DOW_INDEX = 4

    def initialize(cron, command, prefix, regexp)
      @cron = cron
      @command = command
      @prefix = prefix
      @regexp = regexp
    end

    def cloud_watch_cron
      cron_fields = @cron.split(" ")
      cron_fields[DOW_INDEX] = "?" if cron_fields[DOM_INDEX] == "*" && cron_fields[DOW_INDEX] == "*"
      cron_fields << "*" # Year
      cron_fields.join(" ")
    end

    def command
      @command
    end

    def cron
      @cron
    end

    def name
      unless @name
        matched = Regexp.new(@regexp).match(@command)
        @name = "#{@prefix}#{matched ? matched[1] : ""}"
      end

      @name
    end
  end
end
