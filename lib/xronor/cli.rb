module Xronor
  class CLI
    class << self
      def start(argv)
        options = {
          filename: "",
          prefix: DEFAULT_JOB_PREFIX,
          function: "",
          cluster: "",
          task_definition: "",
          container: "",
          dry_run: false,
        }

        OptionParser.new do |opts|
          opts.on("-f, --filename=FILENAME", "Whenever file") { |v| options[:filename] = v }
          opts.on("--prefix=PREFIX", "Job name prefix (default: #{DEFAULT_JOB_PREFIX})") { |v| options[:prefix] = v }
          opts.on("--function=FUNCTION", "Lambda function name") { |v| options[:function] = v }
          opts.on("--cluster=CLUSTER", "ECS cluster") { |v| options[:cluster] = v }
          opts.on("--task-definition=TASK_DEFINITION", "ECS task definition") { |v| options[:task_definition] = v }
          opts.on("--container=CONTAINER", "ECS container name") { |v| options[:container] = v }
          opts.on("--table=TABLE", "DynamoDB lock manager table") { |v| options[:table] = v }
          opts.on("--dry-run", "Dry run" ) { |v| options[:dry_run] = true }

          opts.parse!(argv)
        end

        run(options)
      end

      private

      def run(options)
        jobs = Xronor::Parser.parse(options[:filename])
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
end
