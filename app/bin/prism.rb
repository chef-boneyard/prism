require 'rubygems'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'habistone'
require 'ring_walker'

wavelength = 30
$stdout.sync = true
habistone = Habistone.new

loop do
  t = Time.now
  habistone.emit(habistone.refract(habistone.absorb))
  sleep(t + wavelength - Time.now)
end
