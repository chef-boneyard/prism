require 'toml'

class Habistone
  class MemberConfig
    attr_reader :supervisor_ip

    def initialize(supervisor_ip)
      @supervisor_ip = supervisor_ip
    end

    def get_config
      begin
        config_toml = RestClient.get "http://#{supervisor_ip}:9631/config"
        refract(config_toml)
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
      parsed_toml = TOML::Parser.new(config_toml).parsed
      {
        bind: parsed_toml['bind'],
        hab: parsed_toml['hab'],
        cfg: parsed_toml['cfg'],
        #pkg: project_deps(parsed_toml['pkg'])
        #TODO base package. do separately? can there only be one?
        deps: project_deps(parsed_toml['pkg']['deps'])
      }
    end

    #Flatten deps tree into a package list
    def project_deps(deps_tree)
      deps_list = Array.new
      project_deps_onto(deps_list, deps_tree)
      deps_list
    end

    def project_deps_onto(deps_list, deps_tree)
      deps_tree.each do |dep|
        #TODO better way to make a Set?
        deps_list.push(dep['ident']) unless deps_list.include?(dep['ident'])
        if dep['deps'].any?
          project_deps_onto(deps_list, dep['deps'])
        end
      end
    end
  end
end
