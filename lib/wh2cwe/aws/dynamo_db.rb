module Wh2cwe
  module AWS
    class DynamoDB
      BATCH_WRITE_ITEM_MAX = 25

      def initialize(client: Aws::DynamoDB::Client.new)
        @client = client
      end

      def sync_rule_arns(table, add_rule_arns, delete_rule_arns)
        put_requests = add_rule_arns.map do |arn|
          {
            put_request: {
              item: {
                "ARN" => {
                  s: arn,
                },
                "Timestamp" => {
                  s: "0",
                },
              },
            },
          }
        end

        delete_requests = delete_rule_arns.map do |arn|
          {
            delete_request: {
              key: {
                "ARN" => {
                  s: arn,
                },
              },
            },
          }
        end

        requests = put_requests + delete_requests

        requests.each_slice(BATCH_WRITE_ITEM_MAX) do |reqs|
          @client.batch_write_item({
            request_items: {
              table => reqs,
            },
          })
        end
      end
    end
  end
end
