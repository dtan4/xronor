module Xronor
  module Generator
    class Crontab
      class << self
        def generate(filename, options)
          jobs = Xronor::Parser.parse(filename)

          jobs.each do |job|
            puts <<-EOS
# #{job.name} - #{job.description}
#{[job.schedule, job.command].join(" ")}

        EOS
          end
        end
      end
    end
  end
end
