require 'rest-client'

class Habistone
  def absorb
    puts 'Retrieving census from ring'
    response = RestClient.get 'http://localhost:9631/census'

  end

  def emit
    puts 'Posting to visibility'
  end

  def refract(json)
    ring_census = JSON.parse(json)
    censuses = ring_census['census_list']['censuses']
    service_groups = refract_service_groups(censuses)

    vis_census = {
      :ring_id => 'eb388e2f-9736-4e57-a36a-176451b8a302',
      :last_update => Time.now.strftime('%Y-%m-%dT%H:%M:%SZ'),
      :prism_ip_address => ring_census['me']['ip'],
      :service_groups=> [
        service_groups
      ]
    }
    puts vis_census
    return vis_census
  end

  def refract_service_groups(censuses)
     censuses.each do |census, service_group|
            service_group_name = census[0]
            return {
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


if __FILE__ == $0

  wavelength = 5
  $stdout.sync = true
  loop do
    t = Time.now
    absorb;
    emit;
    sleep(t + wavelength - Time.now)
  end
end
