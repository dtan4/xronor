module Wh2cwe
  class Job
    DOM_INDEX = 2
    DOW_INDEX = 4

    attr_reader :cron, :command

    def initialize(cron, command)
      @cron = cron
      @command = command
    end

    def cloud_watch_cron
      cron_fields = @cron.split(" ")
      cron_fields[DOW_INDEX] = "?" if cron_fields[DOM_INDEX] == "*" && cron_fields[DOW_INDEX] == "*"
      cron_fields << "*" # Year
      cron_fields.join(" ")
    end

    def name(prefix, regexp)
      matched = Regexp.new(regexp).match(@command)
      "#{prefix}#{matched ? matched[1] : ""}"
    end
  end
end
