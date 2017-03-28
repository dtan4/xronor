job_template "/bin/bash -l -c ':job'"

job_type :rake, "bundle exec rake :task RAILS_ENV=production"

default do
  timezone "Asia/Tokyo"
end

every 1.hour, at: 15 do
  name "Send awesome mails"
  rake "send_awesome_mail"
end

every 1.hour, at: 10 do
  name "Update Elasticsearch indices"
  rake "update_elasticsearch"
end

every :day, at: '0:00 am' do
  name "Send greeting notifications"
  description "Send greeting notifications for all users"
  rake "send_greeting_notification"
end

every :day, at: '0:00 am', timezone: "Etc/GMT-1" do
  name "Send notifications for Berlin"
  description "Send notifications for Berlin"
  rake "send_notification[Europe/Berlin]"
end

every :wednesday, at: '0:10 am' do
  name "Create new companies"
  rake "create_new_companies"
end

every "0 10 10,20 * *" do
  name "Healthcheck"
  rake "ping"
end
