require "spec_helper"

module Wh2cwe
  describe Parser do
    describe ".parse" do
      let(:filename) do
        fixture_path("schedule.rb")
      end

      let(:prefix) do
        "scheduler-"
      end

      let(:regexp) do
        "regexp"
      end

      it "should return list of jobs" do
        jobs = described_class.parse(filename, prefix, regexp)
        expect(jobs.length).to eq 4
        jobs.each do |job|
          expect(job).to be_an_instance_of(Wh2cwe::Job)
        end
      end
    end
  end
end
