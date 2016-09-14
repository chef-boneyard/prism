require 'rest-client'
require 'json'
require 'habistone/cli'
require 'habistone/config'
require 'habistone/member_config'

class Habistone
  def initialize
    cli = Habistone::Cli.new
    cli.parse_options
    Habistone::Config.from_file(cli.config[:config_file]) if cli.config[:config_file]
    Habistone::Config.merge!(cli.config)
  end

  def print_configuration
    puts "Data collector url: #{Habistone::Config.data_collector_url}"
    puts "Habitat supervisor host: #{Habistone::Config.supervisor_host}"
    puts "Habitat ring id: #{habitat_ring_id}"
    puts "Habitat ring alias: #{habitat_ring_alias}"
  end

  def run
    begin
      absorbed_findings = absorb
    rescue => e
      $stderr.puts "Unable to absorb data from ring: #{e.message}"
      return
    end

    refracted_data = refract(absorbed_findings)

    begin
      emit(refracted_data)
    rescue => e
      $stderr.puts "Unable to emit data: #{e.message}"
    end
  end

  def absorb
    supervisor_host = Habistone::Config.supervisor_host
    handle_http_exceptions_for { RestClient.get("http://#{supervisor_host}:9631/census").body }
  end

  def emit(message)
    data_collector = Habistone::Config.data_collector_url
    data_collector_token = Habistone::Config.data_collector_token
    handle_http_exceptions_for do
      RestClient::Request.execute(
        method: 'post',
        url: data_collector,
        payload: message.to_json,
        headers: { 'x-data-collector-token' => data_collector_token, 'Content-Type' => 'application/json'},
        verify_ssl: ssl_verify_mode
      )
    end
  end

  def refract(json)
    ring_census = JSON.parse(json)
    censuses = ring_census['census_list']['censuses']
    service_groups = refract_service_groups(censuses)
    {
      ring_id: habitat_ring_id, #TODO: Get ring id from encyrption when encryption is on
      ring_alias: habitat_ring_alias,
      last_update: Time.now.strftime('%Y-%m-%dT%H:%M:%SZ'),
      prism_ip_address: ring_census['me']['ip'],
      service_groups: service_groups
    }
  end

  def refract_service_groups(censuses)
    censuses.map do |census, service_group|
      service_group_name = census
      members = refract_members(service_group['population'])
      {
        name: service_group_name,
        in_event: service_group['in_event'],
        service: service_group['service'],
        group: service_group['group'],
        organization: service_group['organization'],
        members: members
      }
    end
  end

  def refract_members(members)
    vis_members = Hash.new { |hash, key| hash[key] = Hash.new(&hash.default_proc) }
    members.each do |census_id, member|
      member_config = Habistone::MemberConfig.new(member['ip'])
      id = member['member_id']
      vis_members[id]['census_id'] = census_id
      vis_members[id]['member_id'] = member['member_id']
      vis_members[id]['ip'] = member['ip']
      vis_members[id]['leader'] = member['leader']
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
      vis_members[id]['configuration'] = member_config.get_config
    end

    vis_members
  end

  def diffract_status(member)
    if member['alive']
      'alive'
    elsif member['suspect']
      'suspect'
    elsif member['confirmed']
      'confirmed'
    elsif member['detached']
      'detached'
    else
      'unknown'
    end
  end

  private

  def handle_http_exceptions_for(&block)
    yield
  rescue RestClient::ExceptionWithResponse => e
    $stderr.puts "Error making HTTP request: #{e.class} - #{e.response.body}"
    raise
  rescue => e
    $stderr.puts "Error making HTTP request: #{e.class} - #{e.message}"
    raise
  end

  def ssl_verify_mode
    Habistone::Config.ssl_verification_enabled ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE
  end

  def habitat_ring_id
    Habistone::Config.habitat_ring_id.empty? ? SecureRandom.uuid : Habistone::Config.habitat_ring_id
  end

  def habitat_ring_alias
    Habistone::Config.habitat_ring_alias.empty? ? "default" : Habistone::Config.habitat_ring_alias
  end
end
