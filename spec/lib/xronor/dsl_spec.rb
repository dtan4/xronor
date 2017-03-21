require "spec_helper"

module Xronor
  describe DSL do
    describe "#result" do
      let(:body) do
        <<-BODY
every :day, at: "10:30 am" do
  name "Update Elasticsearch"
  description "Update Elasticsearch indices"
end
        BODY
      end

      let(:dsl) do
        described_class.eval(body)
      end

      it "should return Job list" do
        result = dsl.result
        expect(result.jobs.length).to eq 1
      end
    end
  end
end
