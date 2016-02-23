require 'json_spec/cucumber'

require_relative 'assumptions'

$stdout.sync = true
$stderr.sync = true

fail 'CLOUD_ID not set.' unless CLOUD_ID

# Delete logs directory
FileUtils.rm_rf(BASE_DIR + '/COMPONENT_NAME-test/cucumber/logs')


AfterConfiguration do
  UnderTest.start unless ENV['NO_START_UNDERTEST']
end

After do |scenario|
  if scenario.failed?
    STDOUT.puts 'Server log:'
    STDOUT.puts UnderTest.last_log(30)
  end
end

at_exit do
  UnderTest.stop
end