module Xronor
  class Job
    DOM_INDEX = 2
    DOW_INDEX = 4

    POD_NAME_MAX_LENGTH = 253

    def initialize(name, description, schedule, command)
      @name = name
      @description = description
      @schedule = schedule
      @command = command
    end

    attr_reader :command, :description, :name, :schedule

    def cloud_watch_schedule
      cron_fields = @schedule.split(" ")

      if cron_fields[DOM_INDEX] == "*" && cron_fields[DOW_INDEX] == "*"
        cron_fields[DOW_INDEX] = "?"
      else
        cron_fields[DOM_INDEX] = "?" if cron_fields[DOM_INDEX] == "*"

        if cron_fields[DOW_INDEX] == "*"
          cron_fields[DOW_INDEX] = "?"
        else
          cron_fields[DOW_INDEX] = cron_fields[DOW_INDEX].to_i + 1
        end
      end

      cron_fields << "*" # Year
      "cron(#{cron_fields.join(" ")})"
    end

    def cloud_watch_rule_name(prefix)
      "#{prefix}#{@name}-#{hashcode}".gsub(/[^\.\-_A-Za-z0-9]/, "-").downcase
    end

    def k8s_pod_name
      @name.gsub(/[^\.\-A-Za-z0-9]/, "-").downcase[0...POD_NAME_MAX_LENGTH]
    end

    private

    def hashcode
      @hashcode ||= OpenSSL::Digest::SHA256.hexdigest("#{@name}\t#{@description}\t#{@schedule}\t#{@command}")[0..12]
    end
  end
end
