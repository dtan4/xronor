require "spec_helper"

module Xronor
  class DSL
    describe Default do
      let(:default) do
        described_class.new do
          prefix "scheduler-"
          timezone "Asia/Tokyo"
          cron_timezone "UTC"
        end
      end

      describe "#result" do
        it "should parse Default DSL" do
          result = default.result
          expect(result.prefix).to eq "scheduler-"
          expect(result.timezone).to eq "Asia/Tokyo"
          expect(result.cron_timezone).to eq "UTC"
        end
      end
    end
  end
end
