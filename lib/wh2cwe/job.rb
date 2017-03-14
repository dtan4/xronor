module Wh2cwe
  class Job
    DOM_INDEX = 2
    DOW_INDEX = 4

    attr_reader :cron, :task

    def initialize(cron, task)
      @cron = cron
      @task = task
    end

    def cloud_watch_cron
      cron_fields = @cron.split(" ")
      cron_fields[DOW_INDEX] = "?" if cron_fields[DOM_INDEX] == "*" && cron_fields[DOW_INDEX] == "*"
      cron_fields << "*" # Year
      cron_fields.join(" ")
    end

    def name(regexp)
      matched = Regexp.new(regexp).match(@task)
      matched ? matched[1] : ""
    end
  end
end
