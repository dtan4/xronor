require "spec_helper"

module Xronor
  class DSL
    describe NumericSeconds do
      let(:numeric_seconds) do
        described_class.new(number)
      end

      let(:number) do
        1
      end

      describe "#seconds" do
        it "should return seconds" do
          expect(numeric_seconds.seconds).to eq 1
        end
      end

      describe "#minutes" do
        it "should return seconds" do
          expect(numeric_seconds.minutes).to eq 60
        end
      end

      describe "#hours" do
        it "should return seconds" do
          expect(numeric_seconds.hours).to eq 3_600
        end
      end

      describe "#days" do
        it "should return seconds" do
          expect(numeric_seconds.days).to eq 86_400
        end
      end

      describe "#weeks" do
        it "should return seconds" do
          expect(numeric_seconds.weeks).to eq 604_800
        end
      end

      describe "#months" do
        it "should return seconds" do
          expect(numeric_seconds.months).to eq 2_592_000
        end
      end

      describe "#years" do
        it "should return seconds" do
          expect(numeric_seconds.years).to eq 31_557_600
        end
      end
    end
  end
end
