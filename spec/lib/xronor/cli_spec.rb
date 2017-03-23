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
      before do
        allow(Xronor::Generator::ERB).to receive(:generate_all_in_one).and_return(<<-EOS)
# Send awesome mails - Send awesome mails
15 * * * * /bin/bash -l -c 'bundle exec rake send_awesome_mail RAILS_ENV=production'

# Update Elasticsearch indices - Update Elasticsearch indices
10 * * * * /bin/bash -l -c 'bundle exec rake update_elasticsearch RAILS_ENV=production'

# Send greeting notifications - Send greeting notifications for all users
0 15 * * * /bin/bash -l -c 'bundle exec rake send_greeting_notification RAILS_ENV=production'

# Create new companies - Create new companies
10 15 * * 2 /bin/bash -l -c 'bundle exec rake create_new_companies RAILS_ENV=production'

# Healthcheck - Healthcheck
0 10 10,20 * * /bin/bash -l -c 'bundle exec rake ping RAILS_ENV=production'

EOS
      end

      it "should generate text from template" do
        expect do
          described_class.new.invoke("template", [filename], [
            "--template", "/path/to/template",
          ])
        end.to output(<<-EOS).to_stdout
# Send awesome mails - Send awesome mails
15 * * * * /bin/bash -l -c 'bundle exec rake send_awesome_mail RAILS_ENV=production'

# Update Elasticsearch indices - Update Elasticsearch indices
10 * * * * /bin/bash -l -c 'bundle exec rake update_elasticsearch RAILS_ENV=production'

# Send greeting notifications - Send greeting notifications for all users
0 15 * * * /bin/bash -l -c 'bundle exec rake send_greeting_notification RAILS_ENV=production'

# Create new companies - Create new companies
10 15 * * 2 /bin/bash -l -c 'bundle exec rake create_new_companies RAILS_ENV=production'

# Healthcheck - Healthcheck
0 10 10,20 * * /bin/bash -l -c 'bundle exec rake ping RAILS_ENV=production'

EOS
      end
    end

    describe "template_per_job" do
      let(:outdir) do
        Dir.mktmpdir
      end

      before do
        allow(Xronor::Generator::ERB).to receive(:generate_per_job).and_return({
          "send_awesome_mails" => <<-EOS,
# Send awesome mails - Send awesome mails
15 * * * * /bin/bash -l -c 'bundle exec rake send_awesome_mail RAILS_ENV=production'
 EOS
          "update_elasticsearch_indices" => <<-EOS,
# Update Elasticsearch indices - Update Elasticsearch indices
10 * * * * /bin/bash -l -c 'bundle exec rake update_elasticsearch RAILS_ENV=production'
EOS
          "send_greeting_notifications" => <<-EOS,
# Send greeting notifications - Send greeting notifications for all users
0 15 * * * /bin/bash -l -c 'bundle exec rake send_greeting_notification RAILS_ENV=production'
EOS
          "create_new_companies" => <<-EOS,
# Create new companies - Create new companies
10 15 * * 2 /bin/bash -l -c 'bundle exec rake create_new_companies RAILS_ENV=production'
EOS
          "healthcheck" => <<-EOS,
# Healthcheck - Healthcheck
0 10 10,20 * * /bin/bash -l -c 'bundle exec rake ping RAILS_ENV=production'
EOS
})
      end

      after do
        FileUtils.rm_rf(outdir) if Dir.exists?(outdir)
      end

      context "when --ext is given" do
        it "should generate text from template" do
          described_class.new.invoke("template_per_job", [filename], [
            "--outdir", outdir,
            "--template", "/path/to/template",
          ])

          %w(
            send_awesome_mails
            update_elasticsearch_indices
            send_greeting_notifications
            create_new_companies
            healthcheck
          ).each do |name|
            expect(File.exists?(File.join(outdir, name))).to be true
          end

          expect(open(File.join(outdir, "send_awesome_mails")).read).to eq <<-EOS
# Send awesome mails - Send awesome mails
15 * * * * /bin/bash -l -c 'bundle exec rake send_awesome_mail RAILS_ENV=production'
        EOS
        end
      end

      context "when --ext is not given" do
        it "should generate text from template" do
          described_class.new.invoke("template_per_job", [filename], [
            "--ext", "yaml",
            "--outdir", outdir,
            "--template", "/path/to/template",
          ])

          %w(
            send_awesome_mails.yaml
            update_elasticsearch_indices.yaml
            send_greeting_notifications.yaml
            create_new_companies.yaml
            healthcheck.yaml
          ).each do |name|
            expect(File.exists?(File.join(outdir, name))).to be true
          end

          expect(open(File.join(outdir, "send_awesome_mails.yaml")).read).to eq <<-EOS
# Send awesome mails - Send awesome mails
15 * * * * /bin/bash -l -c 'bundle exec rake send_awesome_mail RAILS_ENV=production'
        EOS
        end
      end
    end
  end
end
