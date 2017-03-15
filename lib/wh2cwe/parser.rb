module Wh2cwe
  class Parser
    def self.parse(filename, prefix, regexp)
      Whenever.cron(file: filename).split("\n").delete_if { |line| line == "" }.map do |line|
        fields = line.split(" ")
        cron = fields[0..4].join(" ")
        command = fields[5..-1].join(" ")
        Job.new(cron, command, prefix, regexp)
      end
    end
  end
end
