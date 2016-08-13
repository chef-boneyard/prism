require 'mixlib/cli'

class Habistone
  class Cli
    include Mixlib::CLI

    option :config_file,
           :short => '-c CONFIG',
           :long  => '--config CONFIG',
           :description => 'The path to the configuration file to use'

    option :data_collector_url,
           :long => '--data_collector_url URL',
           :description => 'The data collector endpoint to use'

    option :data_collector_token,
           :long => '--data_collector_token TOKEN',
           :description => 'The data collector token to auth with'

    option :supervisor_host,
           :long => '--supervisor_host HOST',
           :default => 'localhost',
           :description => 'Host that the supervisor is on, often localhost'

    option :habitat_ring_id,
           :long => '--habitat_ring_id UUID',
           :default =>  SecureRandom.uuid,
           :description => 'The unique identifier of the habitat ring.'

    option :habitat_ring_alias,
           :long => '--habitat_ring_alias ALIAS',
           :default => 'default',
           :description => 'The alias of the habitat ring.'
  end
end
