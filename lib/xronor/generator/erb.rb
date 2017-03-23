module Xronor
  module Generator
    class ERB
      class << self
        def generate_all_in_one(filename, options)
          @jobs = Xronor::Parser.parse(filename)
          erb = open(options[:template]).read
          ::ERB.new(erb, nil, "-").result(binding)
        end

        def generate_per_job(filename, options)
          jobs = Xronor::Parser.parse(filename)
          erb = open(options[:template]).read

          jobs.inject({}) do |result, job|
            @job = job
            result[job.name.gsub(/[^\.\-_A-Za-z0-9]/, "_").downcase] = ::ERB.new(erb, nil, "-").result(binding)
            result
          end
        end
      end
    end
  end
end
