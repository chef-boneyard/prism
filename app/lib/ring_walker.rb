require 'rest-client'
require 'json'

class RingWalker

  def walk(supervisor_host)
    gossipJson = retrieveMembers(supervisor_host)
    gossip = JSON.parse(gossipJson)
    members = gossip['member_list']['members']
    # for each member get ip address and query it for config
  end

  def retrieveMembers(supervisor_host)
    begin
      RestClient.get "http://#{supervisor_host}:9631/gossip"
    rescue RestClient::ExceptionWithResponse => e
      puts e.response
    rescue => e
      puts e
    end
  end

  def getConfig(supervisor_ip)
    begin
      RestClient.get "http://#{supervisor_ip}:9631/config"
    rescue RestClient::ExceptionWithResponse => e
      puts e.response
    rescue => e
      puts e
    end
  end

  def refract_config_toml(toml)
  end
end
