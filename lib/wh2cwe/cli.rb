module Wh2cwe
  class CLI
    class << self
      def start(argv)
        options = {
          filename: "",
          prefix: DEFAULT_JOB_PREFIX,
          function: "",
          regexp: "",
          cluster: "",
          task_definition: "",
          container: "",
          dry_run: false,
        }

        OptionParser.new do |opts|
          opts.on("-f, --filename=FILENAME", "Whenever file") { |v| options[:filename] = v }
          opts.on("--prefix=PREFIX", "Job name prefix (default: #{DEFAULT_JOB_PREFIX})") { |v| options[:prefix] = v }
          opts.on("--function=FUNCTION", "Lambda function name") { |v| options[:function] = v }
          opts.on("--regexp=REGEXP", "Regular expression to extract job name") { |v| options[:regexp] = v }
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
        cwe = Wh2cwe::AWS::CloudWatchEvents.new
        dynamodb = Wh2cwe::AWS::DynamoDB.new
        lambda = Wh2cwe::AWS::Lambda.new

        jobs = Wh2cwe::Parser.parse(options[:filename], options[:prefix], options[:regexp])
        function_arn = lambda.retrieve_function_arn(options[:function])

        rule_arns = jobs.map do |job|
          if options[:dry_run]
            puts "[DRYRUN] #{job.name} will be registered to CloudWatch Events"
          else
            arn = cwe.register_job(
              job.name,
              job.cloud_watch_cron,
              options[:cluster],
              options[:task_definition],
              options[:container],
              job.command,
              function_arn,
            )
            puts "Registered #{arn}"
            arn
          end
        end

        if options[:dry_run]
          puts "[DRYRUN] #{rule_arns} will be added to DynamoDB"
        else
          dynamodb.sync_rule_arns(options[:table], rule_arns, [])
        end
      end
    end
  end
end
