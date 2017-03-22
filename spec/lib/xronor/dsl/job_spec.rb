require "spec_helper"

module Xronor
  class DSL
    describe Job do
      let(:frequency) do
        "0 10 10,20 * *"
      end

      let(:options) do
        {}
      end

      let(:job) do
        described_class.new(frequency, options) do
          name "Update Elasticsearch indices"
          description "Update Elasticsearch indices"
        end
      end

      describe "#process_template" do
        let(:process_options) do
          {
            task: "update_elasticsearch",
            rails_env: "production",
          }
        end

        let(:template) do
          "bundle exec rake \":task\" RAILS_ENV=:rails_env"
        end

        it "should processes template" do
          expect(job.process_template(template, process_options)).to eq "bundle exec rake \"update_elasticsearch\" RAILS_ENV=production"
        end
      end

      describe "#result" do
        context "when the given frequency is cron expression" do
          let(:frequency) do
            "0 10 10,20 * *"
          end

          let(:options) do
            {}
          end

          it "should parse Job DSL" do
            result = job.result
            expect(result.description).to eq "Update Elasticsearch indices"
            expect(result.name).to eq "Update Elasticsearch indices"
            expect(result.schedule).to eq "0 10 10,20 * *"
          end
        end

        context "when the given frequency is Symbol" do
          let(:frequency) do
            :day
          end

          let(:options) do
            {
              at: "10:30 am",
            }
          end

          it "should parse Job DSL" do
            result = job.result
            expect(result.description).to eq "Update Elasticsearch indices"
            expect(result.name).to eq "Update Elasticsearch indices"
            expect(result.schedule).to eq ""
          end
        end

        context "when the given frequency is invalid type" do
          let(:frequency) do
            {}
          end

          let(:options) do
            {
              at: "10:30 am",
            }
          end

          it "should raise ArgumentError" do
            expect do
              job.result
            end.to raise_error ArgumentError
          end
        end
      end
    end
  end
end
