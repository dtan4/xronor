require "spec_helper"

module Xronor
  describe Job do
    let(:name) do
      "Create new companies"
    end

    let(:description) do
      "description"
    end

    let(:schedule) do
      "10 0 * * *"
    end

    let(:command) do
      "/bin/bash -l -c 'bundle exec rake create_new_companies RAILS_ENV=production'"
    end

    let(:job) do
      described_class.new(name, description,schedule, command)
    end

    describe "#cloud_watch_schedule" do
      context "when day is specified" do
        let(:schedule) do
          "10 0 3 * *"
        end

        it "should convert standard cron expression to CloudWatch cron expression" do
          expect(job.cloud_watch_schedule).to eq "cron(10 0 3 * ? *)"
        end
      end

      context "when weekday is specified" do
        let(:schedule) do
          "10 0 * * 3"
        end

        it "should convert standard cron expression to CloudWatch cron expression" do
          expect(job.cloud_watch_schedule).to eq "cron(10 0 ? * 4 *)"
        end
      end

      context "when both day and weekday are specified" do
        let(:schedule) do
          "10 0 3 * 3"
        end

        it "should convert standard cron expression to CloudWatch cron expression" do
          expect(job.cloud_watch_schedule).to eq "cron(10 0 3 * 4 *)"
        end
      end

      context "when day and weekday are not specified" do
        let(:schedule) do
          "10 0 * * *"
        end

        it "should convert standard cron expression to CloudWatch cron expression" do
          expect(job.cloud_watch_schedule).to eq "cron(10 0 * * ? *)"
        end
      end
    end

    describe "#cloud_watch_rule_name" do
      let(:prefix) do
        "scheduler-"
      end

      it "should return rule name" do
        expect(job.cloud_watch_rule_name(prefix)).to eq "scheduler-create-new-companies-4e8a044d96c6e"
      end
    end
  end
end
