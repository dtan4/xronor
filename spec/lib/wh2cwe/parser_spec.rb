require "spec_helper"

module Wh2cwe
  describe Parser do
    describe ".parse" do
      let(:filename) { fixture_path("schedule.rb") }

      it "should return list of cron expression and task list" do
        expect(described_class.parse(filename)).to eq([
          { cron: "15 * * * *", command: "/bin/bash -l -c 'bundle exec rake send_awesome_mail RAILS_ENV=production'" },
          { cron: "10 * * * *", command: "/bin/bash -l -c 'bundle exec rake update_elasticsearch RAILS_ENV=production'" },
          { cron: "0 0 * * *", command: "/bin/bash -l -c 'bundle exec rake send_greeting_notification RAILS_ENV=production'" },
          { cron: "10 0 * * *", command: "/bin/bash -l -c 'bundle exec rake create_new_companies RAILS_ENV=production'" },
        ])
      end
    end
  end
end
