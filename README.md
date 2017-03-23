# Xronor

Timezone-aware Job Scheduler DSL and Converter

## Why

### Scheduled job execution system

As you know, Cron is commonly used for scheduled jobs.
However, Cron has some difficulties:

- Does not consider timezone. It depends on machine environment where cron daemon runs.
- Does not contain job metadata (name, description, ...).
- Cron daemon cannot be distributed. Machine where cron daemon runs can be SPOF.

Recently there are solutions for the last point, e.g. [Azure Scheduler](https://azure.microsoft.com/en-us/services/scheduler/), [CloudWatch Events](http://docs.aws.amazon.com/AmazonCloudWatch/latest/events/WhatIsCloudWatchEvents.html) and [Kubernetes Cron Job](https://kubernetes.io/docs/user-guide/cron-jobs/), but those services still have fixed timezone to UTC.

### Scheduler DSL

[Whenever gem](https://github.com/javan/whenever) is very useful to describe scheduled jobs in human-friendly format.
However, Whenever cannot treat timezone and metadata so that it is just a wrapper of Cron expression.

### :point_right:

To resolve above problems, we need:

- _timezone-aware_ job scheduler DSL
  - Just like an enhance of Whenever
- a DSL converter which is easy to register CloudWatch Events rule


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'xronor'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install xronor

## Usage

```
Commands:
  xronor crontab SCHEDULEFILE  xronor cwa SCHEDULEFILE --cluster=CLUSTER --container=CONTAINER --function=FUNCTION --table=TABLE --task-definition=TASK_DEFINITION
  xronor help [COMMAND]
  xronor template SCHEDULEFILE --template=TEMPLATE
  xronor template_per_job SCHEDULERFILE --outdir=OUTDIR --template=TEMPLATE
```

Xronor CLI converts DSL file to:

- CloudWatch Events Rule (required `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY` and `AWS_REGION` environment variables)
- crontab file
- file(s) from ERB template
  - write all jobs in one file
  - generate files per job

## Xronor DSL

Xronor DSL is heavily inspired by [Whenever](https://github.com/javan/whenever) DSL.

```ruby
job_template "/bin/bash -l -c ':job'"

job_type :rake, "bundle exec rake :task RAILS_ENV=production"

default do
  timezone "Asia/Tokyo" # UTC+9
end

every 1.hour, at: 15 do
  name "Send awesome mails"
  rake "send_awesome_mail"
end

every :day, at: '0:00 am' do
  name "Send greeting notifications"
  description "Send greeting notifications for all users"
  rake "send_greeting_notification"
end

every :day, at: '0:00 am', timezone: "Europe/Berlin" do # UTC+1
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
```

will be converted to the below crontab:

```
# Send awesome mails - Send awesome mails
15 * * * * /bin/bash -l -c 'bundle exec rake send_awesome_mail RAILS_ENV=production'

# Update Elasticsearch indices - Update Elasticsearch indices
10 * * * * /bin/bash -l -c 'bundle exec rake update_elasticsearch RAILS_ENV=production'

# Send greeting notifications - Send greeting notifications for all users
0 15 * * * /bin/bash -l -c 'bundle exec rake send_greeting_notification RAILS_ENV=production'

# Send notifications for Berlin - Send notifications for Berlin
0 23 * * * /bin/bash -l -c 'bundle exec rake send_notification[Europe/Berlin] RAILS_ENV=production'

# Create new companies - Create new companies
10 15 * * 2 /bin/bash -l -c 'bundle exec rake create_new_companies RAILS_ENV=production'

# Healthcheck - Healthcheck
0 10 10,20 * * /bin/bash -l -c 'bundle exec rake ping RAILS_ENV=production'
```

### Configuration

```
job_template "/bin/bash -l -c ':job'"

job_type :rake, "bundle exec rake :task RAILS_ENV=production"

default do
  timezone "Asia/Tokyo" # UTC+9
end
```

#### `job_template`

Define common job command template.
`:job` will be replaced to per-job command.

Default: `:job`

#### `job_type` (Required at least one)

Define job type and per-job command template.
`:task` will be replaced to the first argument of job.

For example, the following configuration will generate `/bin/bash -l -c 'bundle exec rake update_elasticsearch'`.

```
job_template "/bin/bash -l -c ':job'"

job_type :rake, "bundle exec rake :task"

every 1.minute do
  rake "update_elasticsearch"
end
```

#### `default`

Set default timezone.
Timezone format follow [tz database](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) (e.g. `UTC`, `Asia/Tokyo`).

|key|description|default|
|---|---|---|
|`timezone`|Timezone of described time in DSL|`UTC`|
|`cron_timezone`|Timezone of the machine where schedule engine runs|`UTC`|

For example, the following configuration will parse `10:30 am` as `10:30 am UTC+9` then convert to `30 1 * * *` (`1:30 am UTC`).

```ruby
default do
  timezone "Asia/Tokyo" # UTC+9
  cron_timezone "UTC"
end
```

### Job definition

```ruby
every :day, at: '0:00 am', timezone: "Europe/Berlin" do # UTC+1
  name "Send notifications for Berlin"
  description "Send notifications for Berlin"
  rake "send_notification[Europe/Berlin]"
end
```

#### `every <frequency> <options> do ... end`

Define job schedule.

Available `<frequency>`:

|key|description|
|---|---|
|`:minute`|Invoke at every minutes|
|`:hour`|Invoke at every hours|
|`:day`|Invoke at every day|
|`N.minutes` (N = 1,2,3,...)|Invoke at every N minutes|
|`N.hours` (N = 1,2,3,...)|Invoke at every N hours|
|`N.days` (N = 1,2,3,...)|Invoke at every N days|
|`0 10 10,20 * *`|Cron expression in `cron_timezone`|

Available `<options>`:

|key|description|
|---|---|
|`at`|Invocation time|
|`timezone`|Timezone of described time in DSL|
|`cron_timezone`|Timezone of the machine where schedule engine runs|

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dtan4/xronor.

## Author

Daisuke Fujita ([@dtan4](https://github.com/dtan4))

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
