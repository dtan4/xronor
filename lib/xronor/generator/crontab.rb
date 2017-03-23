module Xronor
  module Generator
    class Crontab
      class << self
        def generate(filename, options)
          jobs = Xronor::Parser.parse(filename)

          jobs.map do |job|
            <<-EOS
# #{job.name} - #{job.description}
#{[job.schedule, job.command].join(" ")}
EOS
          end.join("\n")
        end
      end
    end
  end
end
