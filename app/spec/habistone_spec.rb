require 'json-schema'
require 'habistone'
require 'json'
require 'support/schema_matcher'
require 'openssl'

describe Habistone do
  let(:habistone) { Habistone.new }

  describe 'JSON Validation' do
    let(:hab_census) { File.read('spec/data/census.json') }
    let(:member_ip)  {"172.17.0.2"}

    it 'Transforms to json matching the schema' do
      #allow(RestClient).to receive(:get).with("http://172.17.0.2:9631/config").and_re
      member_config = double('member_config')
      expect(Habistone::MemberConfig).to receive(:new).with(member_ip).and_return(member_config)
      expect(member_config).to receive(:get_config).and_return("configuration")

      vis_census = habistone.refract(hab_census)
      expect(vis_census).to match_response_schema('ring_census')
    end
  end

  describe 'Setting SSL verification' do
    it 'Disables SSL verification when the config is set to false' do
      Habistone::Config.ssl_verification_enabled = false
      expect(habistone.send(:ssl_verify_mode)).to eq(OpenSSL::SSL::VERIFY_NONE)
    end

    it 'Enables SSL verification when the config is set to true' do
      Habistone::Config.ssl_verification_enabled = true
      expect(habistone.send(:ssl_verify_mode)).to eq(OpenSSL::SSL::VERIFY_PEER)
    end
  end
end
