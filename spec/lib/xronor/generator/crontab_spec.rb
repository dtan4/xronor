require "spec_helper"

module Xronor
  module Generator
    describe Crontab do
      describe ".generate" do
        let(:filename) do
          fixture_path("schedule.rb")
        end

        let(:options) do
          {}
        end

        it "should process ERB template" do
          expect(described_class.generate(filename, options)).to eq <<-EOS
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
    end
  end
end
