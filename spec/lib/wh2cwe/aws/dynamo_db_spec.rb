require "spec_helper"

module Wh2cwe
  module AWS
    describe DynamoDB do
      let(:client) do
        Aws::DynamoDB::Client.new(stub_responses: true)
      end

      let(:dynamo_db) do
        described_class.new(client: client)
      end

      describe "#sync_rule_arns" do
        let(:table) do
          "SchedulerLockManager"
        end

        let(:add_rule_arns) do
          [
            "arn:aws:events:ap-northeast-1:012345678901:rule/scheduler-production-send_awesome_mail",
            "arn:aws:events:ap-northeast-1:012345678901:rule/scheduler-production-update_elasticsearch",
            "arn:aws:events:ap-northeast-1:012345678901:rule/scheduler-production-create_new_companies",
          ]
        end

        let(:delete_rule_arns) do
          [
            "arn:aws:events:ap-northeast-1:012345678901:rule/scheduler-production-send_greeting_notification",
          ]
        end

        before do
          client.stub_responses(:batch_write_item,
            unprocessed_items: {},
            item_collection_metrics: {},
            consumed_capacity: [],
          )
        end

        it "should synchronize rule arns" do
          allow(client).to receive(:batch_write_item).with({
            request_items: {
              "SchedulerLockManager" => [
                {
                  put_request: {
                    item: {
                      "ARN" => "arn:aws:events:ap-northeast-1:012345678901:rule/scheduler-production-send_awesome_mail",
                      "InvokedAt" => "0",
                    },
                  },
                },
                {
                  put_request: {
                    item: {
                      "ARN" => "arn:aws:events:ap-northeast-1:012345678901:rule/scheduler-production-update_elasticsearch",
                      "InvokedAt" => "0",
                    },
                  },
                },
                {
                  put_request: {
                    item: {
                      "ARN" => "arn:aws:events:ap-northeast-1:012345678901:rule/scheduler-production-create_new_companies",
                      "InvokedAt" => "0",
                    },
                  },
                },
                {
                  delete_request: {
                    key: {
                      "ARN" => "arn:aws:events:ap-northeast-1:012345678901:rule/scheduler-production-send_greeting_notification",
                    },
                  },
                },
              ]
            }
          })
          dynamo_db.sync_rule_arns(table, add_rule_arns, delete_rule_arns)
        end
      end
    end
  end
end
