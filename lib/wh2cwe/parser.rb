module Wh2cwe
  class Parser
    def self.parse(filename)
      Whenever.cron(file: filename).split("\n").delete_if { |line| line == "" }.map do |line|
        fields = line.split(" ")
        cron = fields[0..4].join(" ")
        task = fields[5..-1].join(" ")
        { cron: cron, task: task }
      end
    end
  end
end
