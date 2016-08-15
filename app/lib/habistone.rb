require 'rest-client'
require 'json'
require 'habistone/cli'
require 'habistone/config'

class Habistone
  def initialize
    cli = Habistone::Cli.new
    cli.parse_options
    Habistone::Config.from_file(cli.config[:config_file])
    Habistone::Config.merge!(cli.config)
  end

  def absorb
    RestClient.get 'http://localhost:9631/census'
  end

  def emit(message)
    data_collector = Habistone::Config.data_collector_url
    data_collector_token = Habistone::Config.data_collector_token

    RestClient::Request.execute(
      method: 'post',
      url: data_collector,
      payload: message.to_json,
      headers: { 'x-data-collector-token' => data_collector_token }
    )
  end

  def refract(json)
    ring_census = JSON.parse(json)
    censuses = ring_census['census_list']['censuses']
    service_groups = refract_service_groups(censuses)

    {
      :ring_id => 'eb388e2f-9736-4e57-a36a-176451b8a302',
      :last_update => Time.now.strftime('%Y-%m-%dT%H:%M:%SZ'),
      :prism_ip_address => ring_census['me']['ip'],
      :service_groups=> [
        service_groups
      ]
    }
  end

  def refract_service_groups(censuses)
    censuses.each do |census, service_group|
      service_group_name = census[0]
      {
        :name=>service_group_name,
        :in_event=>service_group['in_event'],
        :service=>service_group['service'],
        :group=>service_group['group'],
        :organization=>service_group['organization']
          #TODO members
        }#TODO return all censuses
    end
  end
end
