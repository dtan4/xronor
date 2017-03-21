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

        context "when frequency is weekday" do
          let(:frequency) do
            :wednesday
          end

          it "should convert to cron expression" do
            expect(converter.convert).to eq "30 1 * * 3"
          end

          context "when weekday will be changed" do
            context "Wednesday -> Tuesday" do
              let(:options) do
                {
                  at: "3:30 am",
                  timezone: "Asia/Tokyo",
                  cron_timezone: "UTC",
                }
              end

              it "should convert to cron expression" do
                expect(converter.convert).to eq "30 18 * * 2"
              end
            end

            context "Wedneday -> Thursday" do
              let(:options) do
                {
                  at: "6:30 pm",
                  timezone: "UTC",
                  cron_timezone: "Asia/Tokyo",
                }
              end

              it "should convert to cron expression" do
                expect(converter.convert).to eq "30 3 * * 4"
              end
            end

            context "Sunday -> Saturday" do
              let(:frequency) do
                :sunday
              end

              let(:options) do
                {
                  at: "3:30 am",
                  timezone: "Asia/Tokyo",
                  cron_timezone: "UTC",
                }
              end

              it "should convert to cron expression" do
                expect(converter.convert).to eq "30 18 * * 6"
              end
            end

            context "Saturday -> Sunday" do
              let(:frequency) do
                :saturday
              end

              let(:options) do
                {
                  at: "6:30 pm",
                  timezone: "UTC",
                  cron_timezone: "Asia/Tokyo",
                }
              end

              it "should convert to cron expression" do
                expect(converter.convert).to eq "30 3 * * 0"
              end
            end
          end
        end
      end
    end
  end
end
