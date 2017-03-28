# Xronor DSL

Xronor DSL is heavily inspired by [Whenever](https://github.com/javan/whenever) DSL.

For example,

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

will be converted to the following crontab:

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

## Table of contents

- [Configuration](#configuration)
  * [`job_template`](#job_template)
  * [`job_type` (Required at least one)](#job_type-required-at-least-one)
  * [`default`](#default)
- [Job definition](#job-definition)
  * [`every do ... end`](#every---do--end)
  * [`name` (Required)](#name-required)
  * [`description`](#description)
  * [`job_type` (e.g. `rake`)](#job_type-eg-rake)

## Configuration

```ruby
job_template "/bin/bash -l -c ':job'"

job_type :rake, "bundle exec rake :task RAILS_ENV=production"

default do
  timezone "Asia/Tokyo" # UTC+9
end
```

### `job_template`

Define common job command template.
`:job` will be replaced to per-job command.

Default: `:job`

### `job_type` (Required at least one)

Define job type and per-job command template.
`:task` will be replaced to the first argument of job.

For example, the following configuration will generate `/bin/bash -l -c 'bundle exec rake update_elasticsearch'`.

```ruby
job_template "/bin/bash -l -c ':job'"

job_type :rake, "bundle exec rake :task"

every 1.minute do
  rake "update_elasticsearch"
end
```

### `default`

Set default timezone.
Timezone format follows [tz database](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) (e.g. `UTC`, `Asia/Tokyo`).

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

:warning: __NOTE:__ If the specified timezone has DST, generated crontab expression may differ depending on the date you executed Xronor converter.
For example, `every :day, at: 10:30 am` in `Europe/Berlin` will be converted as

- `30 9 * * *` if you execute Xronor converter from the last Sunday of October to the last Sunday of March
- `30 8 * * *` if you execute Xronor converter during other period

This difference is derived from [Central European Summer Time (CEST)](https://en.wikipedia.org/wiki/Central_European_Summer_Time).

To avoid this, please specify _the difference from GMT_, like `Etc/GMT-2` (equal to `UTC+2`).

## Job definition

```ruby
every :day, at: '0:00 am', timezone: "Europe/Berlin" do # UTC+1
  name "Send notifications for Berlin"
  description "Send notifications for Berlin"
  rake "send_notification[Europe/Berlin]"
end
```

### `every <frequency> <options> do ... end`

Define job schedule.

Available `<frequency>`:

|key|description|
|---|---|
|`:minute`|Invoke at every minute|
|`:hour`|Invoke at every hour|
|`:day`|Invoke at every day|
|`:sunday`, `:monday`, ..., `:saturday`|Invoke at every weekday|
|`N.minutes` (N = 1,2,3,...)|Invoke at every N minutes|
|`N.hours` (N = 1,2,3,...)|Invoke at every N hours|
|`N.days` (N = 1,2,3,...)|Invoke at every N days|
|`0 10 10,20 * *`|Cron expression in `cron_timezone`|

Available `<options>`:

|key|description|
|---|---|
|`at`|Invocation time|
|`timezone`|Timezone of described time in DSL. This overrides default `timezone` value.|
|`cron_timezone`|Timezone of the machine where schedule engine runs. This overrides default `cron_timezone` value.|

### `name` (Required)

Define job name.
Job name must contain alphabets, numbers, hyphen (`-`), underscore (`_`) and period (`.`) only.

### `description`

Define job description.
If `description` is not specified, job name will be used as description.

### `job_type` (e.g. `rake`)

Define job command.
