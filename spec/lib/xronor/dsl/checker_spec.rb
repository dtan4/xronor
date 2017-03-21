require "spec_helper"

module Xronor
  class DSL
    module Checker
      class DummyClass
        include Xronor::DSL::Checker

        def check(key, value)
          required(key, value)
        end
      end

      describe "#require" do
        let(:dummy) do
          DummyClass.new
        end

        context "with String" do
          it "should not raise any Exception" do
            expect do
              dummy.check(:string, "string")
            end.not_to raise_error
          end
        end

        context "with Array" do
          it "should not raise any Exception" do
            expect do
              dummy.check(:array, ["array"])
            end.not_to raise_error
          end
        end

        context "with Hash" do
          it "should not raise any Exception" do
            expect do
              dummy.check(:hash, { key: "value" })
            end.not_to raise_error
          end
        end

        context "with empty String" do
          it "should raise any ValidationError" do
            expect do
              dummy.check(:string, "")
            end.to raise_error Xronor::DSL::Checker::ValidationError
          end
        end

        context "with empty Array" do
          it "should raise any ValidationError" do
            expect do
              dummy.check(:array, [])
            end.to raise_error Xronor::DSL::Checker::ValidationError
          end
        end

        context "with empty Hash" do
          it "should raise any ValidationError" do
            expect do
              dummy.check(:hash, {})
            end.to raise_error Xronor::DSL::Checker::ValidationError
          end
        end

        context "with nil" do
          it "should raise any ValidationError" do
            expect do
              dummy.check(:nil, nil)
            end.to raise_error Xronor::DSL::Checker::ValidationError
          end
        end
      end
    end
  end
end
