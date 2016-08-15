require 'mixlib/cli'

class Habistone
  class Cli
    include Mixlib::CLI

    option :config_file,
           :short => '-c CONFIG',
           :long  => '--config CONFIG',
           :default => '/hab/svc/prism/config/habistone.rb',
           :description => 'The path to the configuration file to use'

    option :data_collector_url,
           :long => '--data_collector_url URL',
           :description => 'The data collector endpoint to use'

    option :data_collector_token,
           :long => '--data_collector_token TOKEN',
           :description => 'The data collector token to auth with'
  end
end
