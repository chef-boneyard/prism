require 'mixlib/cli'

class Habistone
  class Cli
    include Mixlib::CLI

    option :config_file,
           :short => '-c CONFIG',
           :long  => '--config CONFIG',
           :description => 'The configuration file to use'
  end
end
