require "spec_helper"

module Xronor
  class DSL
    describe ScheduleConverter do
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

      describe ".convert" do
        it "should call ScheduleConverter#convert" do
          expect_any_instance_of(described_class).to receive(:convert)
          described_class.convert(frequency, options)
        end
      end

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

        context "when timezone is not changed" do
          let(:options) do
            {
              at: "10:30 am",
              timezone: "UTC",
              cron_timezone: "UTC",
            }
          end

          it "should convert to cron expression" do
            expect(converter.convert).to eq "30 10 * * *"
          end
        end

        context "when frequency is seconds" do
          let(:frequency) do
            30
          end

          it "should raise ArgumentError" do
            expect do
              converter.convert
            end.to raise_error ArgumentError, "Time must be in minutes or higher"
          end
        end

        context "when frequency is :minute" do
          context "when frequency is symbol" do
            let(:frequency) do
              :minute
            end

            it "should convert to cron expression" do
              expect(converter.convert).to eq "* * * * *"
            end
          end
        end

        context "when frequency is N.minutes without offset" do
          let(:frequency) do
            5.minutes
          end

          let(:options) do
            {
              timezone: "Asia/Tokyo",
              cron_timezone: "UTC",
            }
          end

          it "should convert to cron expression" do
            expect(converter.convert).to eq "0,5,10,15,20,25,30,35,40,45,50,55 * * * *"
          end
        end

        context "when frequency is N.minutes with offset" do
          let(:frequency) do
            5.minutes
          end

          let(:options) do
            {
              at: "10:30 am",
              timezone: "Asia/Tokyo",
              cron_timezone: "UTC",
            }
          end

          it "should convert to cron expression" do
            expect(converter.convert).to eq "30,35,40,45,50,55 * * * *"
          end
        end

        context "when frequency is :hour" do
            let(:frequency) do
              :hour
            end

            it "should convert to cron expression" do
              expect(converter.convert).to eq "30 * * * *"
            end
        end

        context "when frequency is N.hours without offset" do
          let(:frequency) do
            4.hours
          end

          let(:options) do
            {
              timezone: "Asia/Tokyo",
              cron_timezone: "UTC",
            }
          end

          it "should convert to cron expression" do
            expect(converter.convert).to eq "0 0,4,8,12,16,20 * * *"
          end
        end

        context "when frequency is N.hours with Time offset" do
          let(:frequency) do
            4.hours
          end

          let(:options) do
            {
              at: "10:30 am",
              timezone: "Asia/Tokyo",
              cron_timezone: "UTC",
            }
          end

          it "should convert to cron expression" do
            expect(converter.convert).to eq "30 1,5,9,13,17,21 * * *"
          end
        end

        context "when frequency is N.hours with Numeric offset" do
          let(:frequency) do
            1.hour
          end

          let(:options) do
            {
              at: 10,
              timezone: "Asia/Tokyo",
              cron_timezone: "UTC",
            }
          end

          it "should convert to cron expression" do
            expect(converter.convert).to eq "10 * * * *"
          end
        end

        context "when frequency is :day" do
          let(:frequency) do
            :day
          end

          it "should convert to cron expression" do
            expect(converter.convert).to eq "30 1 * * *"
          end
        end

        context "when frequency is N.days without offset" do
          let(:frequency) do
            4.days
          end

          let(:options) do
            {
              timezone: "Asia/Tokyo",
              cron_timezone: "UTC",
            }
          end

          it "should convert to cron expression" do
            expect(converter.convert).to eq "0 0 1,5,9,13,17,21,25,29 * *"
          end
        end

        context "when frequency is N.hours with Time offset" do
          let(:frequency) do
            4.days
          end

          let(:options) do
            {
              at: "10:30 am",
              timezone: "Asia/Tokyo",
              cron_timezone: "UTC",
            }
          end

          it "should convert to cron expression" do
            expect(converter.convert).to eq "30 1 1,5,9,13,17,21,25,29 * *"
          end
        end
        context "when frequency is N.hours with Numeric offset" do
          let(:frequency) do
            4.days
          end

          let(:options) do
            {
              at: 10,
              timezone: "Asia/Tokyo",
              cron_timezone: "UTC",
            }
          end

          it "should convert to cron expression" do
            expect(converter.convert).to eq "0 10 1,5,9,13,17,21,25,29 * *"
          end
        end

        [:week, :month, :year].each do |freq|
          context "when frequency is #{freq}" do
            let(:frequency) do
              freq
            end

            it "should raise ArgumentError" do
              expect do
                converter.convert
              end.to raise_error ArgumentError, "Invalid frequency #{freq}"
            end
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

              %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday).each.with_index do |weekday, i|
                context "and today is #{weekday}" do
                  it "should convert to cron expression" do
                    Timecop.freeze(Time.parse("2017-10-#{22 + i} 18:07:36 +0900")) do
                      expect(converter.convert).to eq "30 18 * * 2"
                    end
                  end
                end
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

              %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday).each.with_index do |weekday, i|
                context "and today is #{weekday}" do
                  it "should convert to cron expression" do
                    Timecop.freeze(Time.parse("2017-10-#{22 + i} 18:07:36 +0900")) do
                      expect(converter.convert).to eq "30 3 * * 4"
                    end
                  end
                end
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

              %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday).each.with_index do |weekday, i|
                context "and today is #{weekday}" do
                  it "should convert to cron expression" do
                    Timecop.freeze(Time.parse("2017-10-#{22 + i} 18:07:36 +0900")) do
                      expect(converter.convert).to eq "30 18 * * 6"
                    end
                  end
                end
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

              %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday).each.with_index do |weekday, i|
                context "and today is #{weekday}" do
                  it "should convert to cron expression" do
                    Timecop.freeze(Time.parse("2017-10-#{22 + i} 18:07:36 +0900")) do
                      expect(converter.convert).to eq "30 3 * * 0"
                    end
                  end
                end
              end
            end
          end
        end

        context "when am/pm is omitted from :at" do
          let(:frequency) do
            :day
          end

          [
            { at: "0:00", expr: "0 0 * * *" },
            { at: "00:00", expr: "0 0 * * *" },
            { at: "0:0", expr: "0 0 * * *" },
            { at: "0:30", expr: "30 0 * * *" },
            { at: "1:30", expr: "30 1 * * *" },
            { at: "01:30", expr: "30 1 * * *" },
            { at: "3:30", expr: "30 3 * * *" },
            { at: "03:30", expr: "30 3 * * *" },
            { at: "5:30", expr: "30 5 * * *" },
            { at: "05:30", expr: "30 5 * * *" },
            { at: "7:30", expr: "30 7 * * *" },
            { at: "9:30", expr: "30 9 * * *" },
            { at: "11:30", expr: "30 11 * * *" },
            { at: "12:00", expr: "0 12 * * *" },
            { at: "12:30", expr: "30 12 * * *" },
            { at: "13:30", expr: "30 13 * * *" },
            { at: "15:30", expr: "30 15 * * *" },
            { at: "20:30", expr: "30 20 * * *" },
            { at: "23:30", expr: "30 23 * * *" },
          ].each do |testcase|
            context testcase[:at] do
              let(:options) do
                {
                  at: testcase[:at],
                  timezone: "Asia/Tokyo",
                  cron_timezone: "Asia/Tokyo",
                }
              end

              it "should convert to correct cron expression" do
                expect(converter.convert).to eq testcase[:expr]
              end
            end
          end
        end
      end
    end
  end
end
