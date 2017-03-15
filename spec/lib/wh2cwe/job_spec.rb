require "spec_helper"

module Wh2cwe
  describe Job do
    let(:cron) do
      "10 0 * * *"
    end

    let(:command) do
      "/bin/bash -l -c 'bundle exec rake create_new_companies RAILS_ENV=production'"
    end

    let(:job) do
      Job.new(cron, command)
    end

    describe "#cloud_watch_cron" do
      context "when the job will be invoked every day" do
        it "should convert to CloudWatch cron expression" do
          expect(job.cloud_watch_cron).to eq "10 0 * * ? *"
        end
      end

      context "when the job will be invoked at the specific days" do
        let(:cron) do
          "10 0 1-3 * *"
        end

        it "should convert to CloudWatch cron expression" do
          expect(job.cloud_watch_cron).to eq "10 0 1-3 * * *"
        end
      end

      context "when the job will be invoked at the specific weekdays" do
        let(:cron) do
          "10 0 * * 1-3"
        end

        it "should convert to CloudWatch cron expression" do
          expect(job.cloud_watch_cron).to eq "10 0 * * 1-3 *"
        end
      end
    end

    describe "#name" do
      let(:prefix) do
        "scheduler-"
      end

      context "when valid regexp is given" do
        let(:regexp) do
          'bundle exec rake (\w+) RAILS_ENV=.*\z'
        end

        it "should calculate job name using the given regexp" do
          expect(job.name(prefix, regexp)).to eq "scheduler-create_new_companies"
        end
      end

      context "when invalid regexp is given" do
        let(:regexp) do
          '\Abundle exec rake (\w+) RAILS_ENV=.*\z'
        end

        it "should return empty string" do
          expect(job.name(prefix, regexp)).to eq "scheduler-"
        end
      end
    end
  end
end
