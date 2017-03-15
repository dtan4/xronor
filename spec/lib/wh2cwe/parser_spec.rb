require "spec_helper"

module Wh2cwe
  describe Parser do
    describe ".parse" do
      let(:filename) do
        fixture_path("schedule.rb")
      end

      let(:prefix) do
        "scheduler-"
      end

      let(:regexp) do
        "regexp"
      end

      it "should return list of jobs" do
        [
          { cron: "15 * * * *", command: "/bin/bash -l -c 'bundle exec rake send_awesome_mail RAILS_ENV=production'" },
          { cron: "10 * * * *", command: "/bin/bash -l -c 'bundle exec rake update_elasticsearch RAILS_ENV=production'" },
          { cron: "0 0 * * *", command: "/bin/bash -l -c 'bundle exec rake send_greeting_notification RAILS_ENV=production'" },
          { cron: "10 0 * * *", command: "/bin/bash -l -c 'bundle exec rake create_new_companies RAILS_ENV=production'" },
        ].each do |spec|
          expect(Wh2cwe::Job).to receive(:from_crontab).with(spec[:cron], spec[:command], prefix, regexp)
        end

        jobs = described_class.parse(filename, prefix, regexp)
        expect(jobs.length).to eq 4
      end
    end
  end
end
