require "spec_helper"

module Xronor
  module AWS
    describe Lambda do
      let(:client) do
        Aws::Lambda::Client.new(stub_responses: true)
      end

      let(:lambda) do
        described_class.new(client: client)
      end

      describe "#retrieve_function_arn" do
        let(:functions) do
          [
            {
              function_name: "schedule-app",
              function_arn: "arn:aws:lambda:ap-northeast-1:012345678901:function:schedule-app",
              runtime: "python2.7",
              role: "arn:aws:iam::012345678901:role/service-role/schedule-app",
              handler: "lambda_function.lambda_handler",
              code_size: 10550000,
              description: "Awesome function",
              timeout: 3,
              memory_size: 128,
              last_modified: Time.new("2016-10-06 09:25:00 +0000"),
              code_sha_256: "aaaaaa",
              version: "$LATEST",
              vpc_config: { subnet_ids: [], security_group_ids: [] },
            },
          ]
        end

        before do
          client.stub_responses(:list_functions, functions: functions)
        end

        context "when the given function exists" do
          let(:name) do
            "schedule-app"
          end

          it "should return function ARN" do
            expect(lambda.retrieve_function_arn(name)).to eq "arn:aws:lambda:ap-northeast-1:012345678901:function:schedule-app"
          end
        end

        context "when the given function does not exist" do
          let(:name) do
            "schedule-app-hello"
          end

          it "should return empty string" do
            expect(lambda.retrieve_function_arn(name)).to eq ""
          end
        end
      end
    end
  end
end
