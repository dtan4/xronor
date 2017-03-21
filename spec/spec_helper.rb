require "bundler/setup"
require "xronor"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def fixture_path(name)
  File.expand_path(File.join(__FILE__, "..", "fixtures", name))
end
