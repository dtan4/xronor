require "spec_helper"

module Xronor
  describe CLI do
    let(:filename) do
      "/path/to/schedule-file"
    end

    describe "crontab" do
      it "should generate Crontab Events" do
        expect(Xronor::Generator::Crontab).to receive(:generate)
        described_class.new.invoke("crontab", [filename], [])
      end
    end

    describe "cwa" do
      it "should generate CloudWatch Events" do
        expect(Xronor::Generator::CloudWatchEvents).to receive(:generate)
        described_class.new.invoke("cwa", [filename], [
          "--cluster", "cluster",
          "--function", "function",
          "--task-definition", "taskDefinition",
          "--container", "container",
          "--table", "table",
        ])
      end
    end

    describe "template" do
      it "should generate text from template" do
        expect(Xronor::Generator::ERB).to receive(:generate_all_in_one)
        described_class.new.invoke("template", [filename], [
          "--template", "/path/to/template",
        ])
      end
    end
  end
end
