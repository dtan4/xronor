require "spec_helper"

module Xronor
  describe Parser do
    describe ".parse" do
      let(:filename) do
        fixture_path("schedule.rb")
      end

      context "when DSL is mocked" do
        let(:dsl) do
          double("dsl", result: OpenStruct.new(
            jobs: {
              "Send awesome mails" => OpenStruct.new(
                name: "Send awesome mails",
                description: nil,
                schedule: "15 * * * *",
                command: "/bin/bash -l -c 'bundle exec rake send_awesome_mail RAILS_ENV=production'",
              ),
              "Update Elasticsearch indices" => OpenStruct.new(
                name: "Update Elasticsearch indices",
                description: nil,
                schedule: "10 * * * *",
                command: "/bin/bash -l -c 'bundle exec rake update_elasticsearch RAILS_ENV=production'",
              ),
              "Send greeting notifications" => OpenStruct.new(
                name: "Send greeting notifications",
                description: "Send greeting notifications for all users",
                schedule: "0 15 * * *",
                command: "/bin/bash -l -c 'bundle exec rake send_greeting_notification RAILS_ENV=production'",
              ),
              "Send notifications for Berlin" => OpenStruct.new(
                name: "Send notifications for Berlin",
                description: "Send notifications for Berlin",
                schedule: "0 23 * * *",
                command: "/bin/bash -l -c 'bundle exec rake send_notification[Europe/Berlin] RAILS_ENV=production'",
              ),
              "Create new companies" => OpenStruct.new(
                name: "Create new companies",
                description: nil,
                schedule: "10 15 * * 2",
                command: "/bin/bash -l -c 'bundle exec rake create_new_companies RAILS_ENV=production'",
              ),
              "Healthcheck" => OpenStruct.new(
                name: "Healthcheck",
                description: nil,
                schedule: "0 10 10,20 * *",
                command: "/bin/bash -l -c 'bundle exec rake ping RAILS_ENV=production'",
              ),
            },
          ))
        end

        before do
          allow(Xronor::DSL).to receive(:eval).and_return(dsl)
        end

        it "should return list of jobs" do
          [
            {
              name: "Send awesome mails",
              description: "Send awesome mails",
              schedule: "15 * * * *",
              command: "/bin/bash -l -c 'bundle exec rake send_awesome_mail RAILS_ENV=production'",
            },
            {
              name: "Update Elasticsearch indices",
              description: "Update Elasticsearch indices",
              schedule: "10 * * * *",
              command: "/bin/bash -l -c 'bundle exec rake update_elasticsearch RAILS_ENV=production'",
            },
            {
              name: "Send greeting notifications",
              description: "Send greeting notifications for all users",
              schedule: "0 15 * * *",
              command: "/bin/bash -l -c 'bundle exec rake send_greeting_notification RAILS_ENV=production'",
            },
            {
              name: "Send notifications for Berlin",
              description: "Send notifications for Berlin",
              schedule: "0 23 * * *",
              command: "/bin/bash -l -c 'bundle exec rake send_notification[Europe/Berlin] RAILS_ENV=production'",
            },
            {
              name: "Create new companies",
              description: "Create new companies",
              schedule: "10 15 * * 2",
              command: "/bin/bash -l -c 'bundle exec rake create_new_companies RAILS_ENV=production'",
            },
            {
              name: "Healthcheck",
              description: "Healthcheck",
              schedule: "0 10 10,20 * *",
              command: "/bin/bash -l -c 'bundle exec rake ping RAILS_ENV=production'",
            },
          ].each do |spec|
            expect(Xronor::Job).to receive(:new).with(spec[:name], spec[:description], spec[:schedule], spec[:command])
          end

          jobs = described_class.parse(filename)
          expect(jobs.length).to eq 6
        end
      end

      context "when DSL is not mocked" do
        it "should return list of jobs" do
          [
            {
              name: "Send awesome mails",
              description: "Send awesome mails",
              schedule: "15 * * * *",
              command: "/bin/bash -l -c 'bundle exec rake send_awesome_mail RAILS_ENV=production'",
            },
            {
              name: "Update Elasticsearch indices",
              description: "Update Elasticsearch indices",
              schedule: "10 * * * *",
              command: "/bin/bash -l -c 'bundle exec rake update_elasticsearch RAILS_ENV=production'",
            },
            {
              name: "Send greeting notifications",
              description: "Send greeting notifications for all users",
              schedule: "0 15 * * *",
              command: "/bin/bash -l -c 'bundle exec rake send_greeting_notification RAILS_ENV=production'",
            },
            {
              name: "Send notifications for Berlin",
              description: "Send notifications for Berlin",
              schedule: "0 23 * * *",
              command: "/bin/bash -l -c 'bundle exec rake send_notification[Europe/Berlin] RAILS_ENV=production'",
            },
            {
              name: "Create new companies",
              description: "Create new companies",
              schedule: "10 15 * * 2",
              command: "/bin/bash -l -c 'bundle exec rake create_new_companies RAILS_ENV=production'",
            },
            {
              name: "Healthcheck",
              description: "Healthcheck",
              schedule: "0 10 10,20 * *",
              command: "/bin/bash -l -c 'bundle exec rake ping RAILS_ENV=production'",
            },
          ].each do |spec|
            expect(Xronor::Job).to receive(:new).with(spec[:name], spec[:description], spec[:schedule], spec[:command])
          end

          jobs = described_class.parse(filename)
          expect(jobs.length).to eq 6
        end
      end
    end
  end
end
