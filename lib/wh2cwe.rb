require "aws-sdk-core"
require "openssl"
require "optparse"
require "shellwords"
require "whenever"

require "wh2cwe/aws/cloud_watch_events"
require "wh2cwe/aws/dynamo_db"
require "wh2cwe/aws/lambda"
require "wh2cwe/cli"
require "wh2cwe/job"
require "wh2cwe/parser"
require "wh2cwe/version"

module Wh2cwe
  DEFAULT_JOB_PREFIX = "scheduler-"
end
