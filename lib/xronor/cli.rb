module Xronor
  class CLI < Thor
    DEFAULT_JOB_PREFIX = "scheduler-"

    desc "crontab SCHEDULEFILE", "Generate crontab file"
    def crontab(filename)
      body = Xronor::Generator::Crontab.generate(filename, options)
      puts body
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

    desc "template SCHEDULEFILE", "Generate single file"
    option :template, required: true
    def template(filename)
      body = Xronor::Generator::ERB.generate_all_in_one(filename, options)
      puts body
    end

    desc "template_per_job SCHEDULERFILE", "Generate files per job"
    option :ext, default: nil
    option :outdir, required: true
    option :template, required: true
    def template_per_job(filename)
      contents = Xronor::Generator::ERB.generate_per_job(filename, options)

      contents.each do |name, body|
        path = File.join(options[:outdir], options[:ext] ? "#{name}.#{options[:ext]}" : name)
        open(path, "w+") { |f| f.puts body }
      end
    end
  end
end
