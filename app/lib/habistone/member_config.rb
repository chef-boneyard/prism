require "toml"

class Habistone
  class MemberConfig
    attr_reader :supervisor_ip, :service_name, :group_name

    def initialize(params = {})
      @supervisor_ip = params[:ip]
      @service_name  = params[:service]
      @group_name    = params[:group]
      @has_butterfly = params[:has_butterfly]
    end

    def get_config
      begin
        config_toml = RestClient.get(config_url).body
        refract(config_toml)
      rescue RestClient::ExceptionWithResponse => e
        {
          error: {
            status: e.http_code,
            message: e.response.body,
          },
        }
      rescue => e
        {
          error: {
            message: e.message,
          },
        }
      end
    end

    def refract(config_toml)
      parsed_toml = TOML::Parser.new(config_toml).parsed
      {
        bind: parsed_toml["bind"],
        hab: parsed_toml["hab"],
        cfg: parsed_toml["cfg"],
        pkg: parsed_toml["pkg"]["ident"],
        deps: project_deps(parsed_toml["pkg"]["deps"]),
        sys: parsed_toml["sys"],
      }
    end

    # Flatten deps tree into a package list
    def project_deps(deps_tree)
      deps_list = Set.new
      project_deps_onto(deps_list, deps_tree)
      deps_list.to_a
    end

    def project_deps_onto(deps_list, deps_tree)
      deps_tree.each do |dep|
        deps_list.add(dep["ident"])
        project_deps_onto(deps_list, dep["deps"]) unless dep["deps"].nil? || dep["deps"].empty?
      end
    end

    private

    def has_butterfly?
      @has_butterfly
    end

    def config_url
      if has_butterfly?
        "http://#{supervisor_ip}:9631/services/#{service_name}/#{group_name}/config"
      else
        "http://#{supervisor_ip}:9631/config"
      end
    end
  end
end
