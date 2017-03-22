require "spec_helper"

module Xronor
  describe DSL do
    describe "#result" do
      let(:body) do
        <<-BODY
job_template "/bin/bash -l -c ':job'"

job_type :rake, "bundle exec rake :task RAILS_ENV=production"
job_type :runner, "bin/rails runner ':task' RAILS_ENV=production"

default do
  prefix "scheduler-"
  timezone "Asia/Tokyo"
  cron_timezone "UTC"
end

every :day, at: "10:30 am" do
  name "Update Elasticsearch"
  description "Update Elasticsearch indices"
  rake "update_elasticsearch"
end

every "0 12 10,20 * *" do
  name "Send reports"
  runner "script/send_reports"
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
        expect(result.jobs[0].command).to eq "/bin/bash -l -c 'bundle exec rake update_elasticsearch RAILS_ENV=production'"
        expect(result.jobs[1].command).to eq  "/bin/bash -l -c 'bin/rails runner '\\''script/send_reports'\\'' RAILS_ENV=production'"
      end
    end
  end
end
