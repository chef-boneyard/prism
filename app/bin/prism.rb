$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

require "rubygems"
require "bundler/setup"
require "habistone"

def sleep_interval(start_time, end_time, wavelength)
  proposed_sleep = start_time + wavelength - end_time
  proposed_sleep > 0 ? proposed_sleep : wavelength
end

wavelength = 30
$stdout.sync = true
$stderr.sync = true
habistone = Habistone.new
habistone.print_configuration

loop do
  t = Time.now
  habistone.run
  sleep(sleep_interval(t, Time.now, wavelength))
end
