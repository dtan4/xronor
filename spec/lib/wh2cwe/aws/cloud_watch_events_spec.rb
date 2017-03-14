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
          allow(client).to receive(:put_rule).with({
            name: "scheduler-production-create_new_companies",
            schedule_expression: "10 0 * * ? *",
          }).and_return(double("response", rule_arn: "arn:aws:events:ap-northeast-1:012345678901:rule/scheduler-production-create_new_companies"))
          allow(client).to receive(:put_targets).with({
            rule: "scheduler-production-create_new_companies",
            targets: [
              {
                id: "id",
                arn: "arn:aws:lambda:ap-northeast-1:012345678901:function:schedule-app",
                input_transformer: {
                  input_paths_map: {
                    "resources" => "$.resources",
                    "time" => "$.time",
                  },
                  input_template: %q({"resources":<resources>,"time":<time>,"cluster":"scheduler","task_definition":"scheduler-app","container":"scheduler-app","command":["/bin/bash","-l","-c","bundle exec rake create_new_companies RAILS_ENV=production"]}),
                },
              },
            ],
          })
          allow(cwe).to receive(:generate_id).and_return("id")
          expect(cwe.register_job(name, cron, cluster, task_definition, container, command, target_function_arn)).to eq "arn:aws:events:ap-northeast-1:012345678901:rule/scheduler-production-create_new_companies"
        end
      end
    end
  end
end
