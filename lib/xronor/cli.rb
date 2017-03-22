module Xronor
  class CLI < Thor
    DEFAULT_JOB_PREFIX = "scheduler-"

    desc "crontab SCHEDULEFILE", "Generate crontab file"
    def crontab(filename)
      jobs = Xronor::Parser.parse(filename)

      jobs.each do |job|
        puts <<-EOS
# #{job.name} - #{job.description}
#{[job.schedule, job.command].join(" ")}

        EOS
      end
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
      jobs = Xronor::Parser.parse(filename)
      function_arn = lambda.retrieve_function_arn(options[:function])

      current_jobs = cwe.list_jobs(options[:prefix])
      add_jobs, delete_jobs = compare_jobs(options[:prefix], current_jobs, jobs)

      added_rule_arns = add_jobs.map do |job|
        if options[:dry_run]
          puts "[DRYRUN] #{job.name} will be registered to CloudWatch Events"
        else
          arn = cwe.register_job(
            job,
            options[:prefix],
            options[:cluster],
            options[:task_definition],
            options[:container],
            function_arn,
          )
          puts "Registered #{arn}"
          arn
        end
      end

      if options[:dry_run]
      else
        dynamodb.sync_rule_arns(options[:table], added_rule_arns, [])
      end

      delete_jobs.each do |job|
        if options[:dry_run]
          puts "[DRYRUN] #{job} will be deregistered from CloudWatch Events"
        else
          cwe.deregister_job(job)
          puts "Deregistered #{job}"
        end
      end
    end

    private

    def compare_jobs(prefix, current_jobs, next_jobs)
      add_jobs, delete_jobs = [], []
      next_job_names = next_jobs.map do |job|
        job.cloud_watch_rule_name(prefix)
      end

      next_jobs.each do |job|
        add_jobs << job unless current_jobs.include?(job.cloud_watch_rule_name(prefix))
      end

      current_jobs.each do |job|
        delete_jobs << job unless next_job_names.include?(job)
      end

      return add_jobs, delete_jobs
    end

    def cwe
      @cwe ||= Xronor::AWS::CloudWatchEvents.new
    end

    def dynamodb
      @dynamodb ||= Xronor::AWS::DynamoDB.new
    end

    def lambda
      @lambda ||= Xronor::AWS::Lambda.new
    end
  end
end
