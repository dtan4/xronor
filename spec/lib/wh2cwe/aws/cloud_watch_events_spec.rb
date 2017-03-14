require "spec_helper"

module Wh2cwe
  module AWS
    describe CloudWatchEvents do
      let(:client) do
        Aws::CloudWatchEvents::Client.new(stub_responses: true)
      end

      let(:cwe) do
        described_class.new(client: client)
      end

      describe "#register_job" do
        let(:name) do
          "scheduler-production-create_new_companies"
        end

        let(:cron) do
          "10 0 * * ? *"
        end

        let(:cluster) do
          "scheduler"
        end

        let(:task_definition) do
          "scheduler-app"
        end

        let(:container) do
          "scheduler-app"
        end

        let(:command) do
          "/bin/bash -l -c 'bundle exec rake create_new_companies RAILS_ENV=production'"
        end

        let(:target_function_arn) do
          "arn:aws:lambda:ap-northeast-1:012345678901:function:schedule-app"
        end

        let(:rule_arn) do
          "arn:aws:events:ap-northeast-1:012345678901:rule/scheduler-production-create_new_companies"
        end

        before do
          client.stub_responses(:put_rule, rule_arn: rule_arn)
          client.stub_responses(:put_targets, failed_entry_count: 0, failed_entries: [])
        end

        it "should return rule ARN" do
          expect(cwe.register_job(name, cron, cluster, task_definition, container, command, target_function_arn)).to eq "arn:aws:events:ap-northeast-1:012345678901:rule/scheduler-production-create_new_companies"
        end
      end
    end
  end
end
