class Habistone
  class MemberConfig
    attr_reader :supervisor_ip

    def initialize(supervisor_ip)
      @supervisor_ip = supervisor_ip
    end

    def get_config
      begin
        config_toml = RestClient.get "http://#{supervisor_ip}:9631/config"
        refract_config_toml(config_toml)
      rescue RestClient::ExceptionWithResponse => e
        {
          error: {
            status: e.http_code,
            message: e.response.body
          }
        }
      rescue => e
        {
          error: {
            message: e.message
          }
        }
      end
    end

    def refract(config_toml)
    end
  end
end
