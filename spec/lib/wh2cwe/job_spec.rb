require "spec_helper"

module Wh2cwe
  describe Job do
    describe "#name" do
      let(:cron) do
        "10 0 * * *"
      end

      let(:task) do
        "/bin/bash -l -c 'bundle exec rake create_new_companies RAILS_ENV=production'"
      end

      let(:job) do
        Job.new(cron, task)
      end

      context "when valid regexp is given" do
        let(:regexp) do
          'bundle exec rake (\w+) RAILS_ENV=.*\z'
        end

        it "should extract task name using the given regexp" do
          expect(job.name(regexp)).to eq "create_new_companies"
        end
      end

      context "when invalid regexp is given" do
        let(:regexp) do
          '\Abundle exec rake (\w+) RAILS_ENV=.*\z'
        end

        it "should return empty string" do
          expect(job.name(regexp)).to eq ""
        end
      end
    end
  end
end
