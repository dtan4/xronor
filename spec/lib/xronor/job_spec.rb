require "spec_helper"

module Xronor
  describe Job do
    describe ".from_crontab" do
      let(:cron) do
        "10 0 * * *"
      end

      let(:command) do
        "/bin/bash -l -c 'bundle exec rake create_new_companies RAILS_ENV=production'"
      end

      let(:prefix) do
        "scheduler-"
      end

      let(:regexp) do
        ""
      end

      let(:job) do
        described_class.from_crontab(cron, command, prefix, regexp)
      end

      context "when valid regexp is given" do
        let(:regexp) do
          'bundle exec rake (\w+) RAILS_ENV=.*\z'
        end

        it "should calculate job name using the given regexp" do
          expect(job.name).to eq "scheduler-create_new_companies"
        end
      end

      context "when invalid regexp is given" do
        let(:regexp) do
          '\Abundle exec rake (\w+) RAILS_ENV=.*\z'
        end

        it "should return empty string" do
          expect(job.name).to eq "scheduler-"
        end
      end

      context "when the job will be invoked at the specific days" do
        let(:cron) do
          "10 0 1-3 * *"
        end

        it "should convert to CloudWatch cron expression" do
          expect(job.schedule).to eq "cron(10 0 1-3 * * *)"
        end
      end

      context "when the job will be invoked at the specific weekdays" do
        let(:cron) do
          "10 0 * * 1-3"
        end

        it "should convert to CloudWatch cron expression" do
          expect(job.schedule).to eq "cron(10 0 * * 1-3 *)"
        end
      end
    end

    let(:name) do
      "scheduler-production-create_new_companies"
    end

    let(:description) do
      "description"
    end

    let(:schedule) do
      "cron(10 0 * * ? *)"
    end

    let(:command) do
      "/bin/bash -l -c 'bundle exec rake create_new_companies RAILS_ENV=production'"
    end

    let(:job) do
      described_class.new(name, description,schedule, command)
    end

    describe "#cloud_watch_schedule" do
      context "when weekday is specified" do
        let(:schedule) do
          "10 0 * * 3"
        end

        it "should convert standard cron expression to CloudWatch cron expression" do
          expect(job.cloud_watch_schedule).to eq "cron(10 0 * * 3 *)"
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

    describe "#rule_name" do
      let(:job) do
        described_class.new(
          "scheduler-production-create_new_companies",
          "description",
          "cron(10 0 * * ? *)",
          "/bin/bash -l -c 'bundle exec rake create_new_companies RAILS_ENV=production'",
        )
      end

      it "should return rule name" do
        expect(job.rule_name).to eq "scheduler-production-create_new_companies-32343ed63f077"
      end
    end
  end
end
