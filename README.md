# Xronor

[![Build Status](https://travis-ci.org/dtan4/xronor.svg?branch=master)](https://travis-ci.org/dtan4/xronor)
[![codecov](https://codecov.io/gh/dtan4/xronor/branch/master/graph/badge.svg)](https://codecov.io/gh/dtan4/xronor)

Timezone-aware Job Scheduler DSL and Converter

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

## Table of contents

- [Why](#why)
  * [Scheduled job execution system](#scheduled-job-execution-system)
  * [Scheduler DSL](#scheduler-dsl)
  * [:point_right:](#point_right)
- [Installation](#installation)
- [Usage](#usage)
- [Xronor DSL](#xronor-dsl)
- [Development](#development)
- [Contributing](#contributing)
- [Author](#author)
- [License](#license)

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

:point_right: [docs/dsl](docs/dsl.md)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dtan4/xronor.

## Author

Daisuke Fujita ([@dtan4](https://github.com/dtan4))

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
