require "spec_helper"

module Xronor
  class DSL
    describe ScheduleConverter do
      let(:converter) do
        described_class.new(frequency, options)
      end

      describe "#convert" do
        let(:frequency) do
          :day
        end

        let(:options) do
          {
            at: "10:30 am",
            timezone: "Asia/Tokyo",
            cron_timezone: "UTC",
          }
        end

        context "when frequency is :day" do
          let(:frequency) do
            :day
          end

          it "should convert to cron expression" do
            expect(converter.convert).to eq "30 1 * * *"
          end
        end
      end
    end
  end
end
