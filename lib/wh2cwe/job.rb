module Wh2cwe
  class Job
    attr_reader :cron, :task

    def initialize(cron, task)
      @cron = cron
      @task = task
    end

    def name(regexp)
      matched = Regexp.new(regexp).match(@task)
      matched ? matched[1] : ""
    end
  end
end
