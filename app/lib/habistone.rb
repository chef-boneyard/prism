require 'rest-client'
require 'json'
require 'habistone/cli'
require 'habistone/config'

class Habistone
  def initialize
    cli = Habistone::Cli.new
    cli.parse_options
    if cli.config[:config_file]
      puts "Loading from config file #{cli.config[:config_file]}"
      Habistone::Config.from_file(cli.config[:config_file])
      Habistone::Config.merge!(cli.config)
      puts "Data collector url: #{Habistone::Config.data_collector_url}"
      puts "Habitat supervisor host: #{Habistone::Config.supervisor_host}"
      puts "Habitat ring id: #{Habistone::Config.habitat_ring_id}"
      puts "Habitat ring alias: #{Habistone::Config.habitat_ring_alias}"
    end
  end

  def absorb
    supervisor_host = Habistone::Config.supervisor_host
    begin
      RestClient.get "http://#{supervisor_host}:9631/census"
    rescue RestClient::ExceptionWithResponse => e
      puts e.response
    rescue => e
      puts e
    end
  end

  def emit(message)
    data_collector = Habistone::Config.data_collector_url
    data_collector_token = Habistone::Config.data_collector_token
    begin
      RestClient::Request.execute(
        method: 'post',
        url: data_collector,
        payload: message.to_json,
        headers: { 'x-data-collector-token' => data_collector_token, 'Content-Type' => 'application/json'},
        verify_ssl: ssl_verify_mode
      )
    rescue RestClient::ExceptionWithResponse => e
      puts e.response
    rescue => e
      puts e
    end
  end

  def refract(json)
    ring_census = JSON.parse(json)
    censuses = ring_census['census_list']['censuses']
    service_groups = refract_service_groups(censuses)
    {
      :ring_id => Habistone::Config.habitat_ring_id, #TODO: Get ring id from encyrption when encryption is on
      :ring_alias => Habistone::Config.habitat_ring_alias,
      :last_update => Time.now.strftime('%Y-%m-%dT%H:%M:%SZ'),
      :prism_ip_address => ring_census['me']['ip'],
      :service_groups=>service_groups
    }
  end

  def refract_service_groups(censuses)
    censuses.map do |census, service_group|
      service_group_name = census
      members = refract_members(service_group['population'])
      {
        :name=>service_group_name,
        :in_event=>service_group['in_event'],
        :service=>service_group['service'],
        :group=>service_group['group'],
        :organization=>service_group['organization'],
        :members=>members
      }
    end
  end

  def refract_members(members)
    vis_members = Hash.new { |hash, key| hash[key] = Hash.new(&hash.default_proc) }
    members.each do |census_id, member|
      id = member['member_id']
      vis_members[id]['census_id'] = census_id
      vis_members[id]['member_id'] = member['member_id']
      vis_members[id]['hostname'] = member['hostname']
      vis_members[id]['status'] = diffract_status(member)
      vis_members[id]['vote'] = member['vote']
      vis_members[id]['election'] = member['election']
      vis_members[id]['needs_write'] = member['needs_write']
      vis_members[id]['initialized'] = member['initialized']
      vis_members[id]['suitability'] = member['suitability']
      vis_members[id]['port'] = member['port']
      vis_members[id]['exposes'] = member['exposes']
      vis_members[id]['incarnation'] = member['incarnation']
    end
    return vis_members
  end

  def diffract_status(member)
    if member['alive']
      return 'alive'
    elseif member['suspect']
      return 'suspect'
    elseif member['confirmed']
      return 'confirmed'
    elseif member['detached']
      return 'detached'
    end
  end

  private

  def ssl_verify_mode
    Habistone::Config.ssl_verification_enabled ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
  end
end
