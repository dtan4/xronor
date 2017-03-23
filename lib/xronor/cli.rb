module Xronor
  class CLI < Thor
    DEFAULT_JOB_PREFIX = "scheduler-"

    desc "crontab SCHEDULEFILE", "Generate crontab file"
    def crontab(filename)
      Xronor::Generator::Crontab.generate(filename, options)
    end

    desc "cwa SCHEDULEFILE", "Register CloudWatch Events - Scheduler & ECS job runner"
    option :prefix, default: DEFAULT_JOB_PREFIX
    option :function, required: true
    option :cluster, required: true
    option :task_definition, required: true
    option :container, required: true
    option :table, required: true
    option :dry_run, type: :boolean, default: false
    def cwa(filename)
      Xronor::Generator::CloudWatchEvents.generate(filename, options)
    end
  end
end
