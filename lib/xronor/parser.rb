module Xronor
  class Parser
    def self.parse(filename)
      body = open(filename).read
      result = Xronor::DSL.eval(body).result

      result.jobs.values.map do |job|
        job.description ||= job.name
        Xronor::Job.new(job.name, job.description, job.schedule, job.command)
      end
    end
  end
end
