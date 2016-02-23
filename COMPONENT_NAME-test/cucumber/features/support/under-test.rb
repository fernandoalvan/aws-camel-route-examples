require 'singleton'
require 'process-helper'

class UnderTest

  def initialize(opts = {})
    opts = {
        :base_url => UnderTest.base_url
    }.merge(opts)

    @base_url = opts[:base_url]
  end

  def self.start
    @process = ProcessHelper::ProcessHelper.new
    args = ["#{BASE_DIR}/run"]
    STDOUT.puts 'Starting application...'
    @process.start(args, /(Started SelectChannelConnector)/,  wait_timeout=240)
    @startup_log = @process.get_log(:out).to_s

    if @startup_log.match(/(Shutdown hook complete)/)
      puts @startup_log
      stop
      fail 'Startup error detected - aborting'
    end
  end

  def self.stop
    stop_process = ProcessHelper::ProcessHelper.new
    args = ["#{BASE_DIR}/stop_jetty"]
    STDOUT.puts 'Stopping application...'
    stop_process.start(args, /(BUILD SUCCESSFUL)/,  wait_timeout=240)

    unless @process.nil?
      @process.kill
      @process.wait_for_exit
    end
    @process = nil

  end

  def self.last_log(max_lines = 0)
    return ['(Process under test not managed by Cucumber.)'] if @process.nil?
    log = @process.get_log(:out) + @process.get_log(:err)
    if max_lines > 0
      return log.last(max_lines)
    else
      return log
    end
  end

end