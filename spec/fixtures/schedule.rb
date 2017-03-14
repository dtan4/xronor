job_type :rake, "bundle exec rake :task RAILS_ENV=production"

every 1.hour, at: 15 do
  rake "send_awesome_mail"
end

every 1.hour, at: 10 do
  rake "update_elasticsearch"
end

every :day, at: '0:00 am' do
  rake "send_greeting_notification"
end

every :day, at: '0:10 am' do
  rake "create_new_companies"
end
