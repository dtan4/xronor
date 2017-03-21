require "spec_helper"

module Xronor
  class DSL
    describe Job do
      let(:frequency) do
        :day
      end

      let(:options) do
        {
          at: "10:30 am",
        }
      end

      let(:job) do
        described_class.new(frequency, options) do
          name "Update Elasticsearch indices"
          description "Update Elasticsearch indices"
        end
      end

      describe "#result" do
        it "should parse Job DSL" do
          result = job.result
          expect(result.description).to eq "Update Elasticsearch indices"
          expect(result.name).to eq "Update Elasticsearch indices"
        end
      end
    end
  end
end
