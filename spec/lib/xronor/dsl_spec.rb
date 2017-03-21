require "spec_helper"

module Xronor
  describe DSL do
    describe "#result" do
      let(:body) do
        <<-BODY
default do
  prefix "scheduler-"
  timezone "Asia/Tokyo"
  cron_timezone "UTC"
end

every :day, at: "10:30 am" do
  name "Update Elasticsearch"
  description "Update Elasticsearch indices"
end

every "0 12 10,20 * *" do
  name "Send reports"
end
        BODY
      end

      let(:dsl) do
        described_class.eval(body)
      end

      it "should parse DSL" do
        result = dsl.result
        expect(result.options).to be_a Hash
        expect(result.jobs.length).to eq 2
      end
    end
  end
end
