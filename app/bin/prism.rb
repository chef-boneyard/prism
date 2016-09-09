require 'rubygems'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'habistone'

wavelength = 30
$stdout.sync = true
habistone = Habistone.new

loop do
  t = Time.now
  habistone.run
  sleep(t + wavelength - Time.now)
end
