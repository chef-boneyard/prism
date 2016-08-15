require 'mixlib/config'

class Habistone
  class Config
    extend Mixlib::Config
    config_strict_mode true
    default :data_collector_url, 'http://localhost/data-collector/v0/'
    default :data_collector_token, '93a49a4f2482c64126f7b6015e6b0f30284287ee4054ff8807fb63d9cbd1c506'
  end
end
