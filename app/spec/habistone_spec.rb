require 'json-schema'
require 'habistone'
require 'json'
require 'support/schema_matcher'
require 'openssl'

describe Habistone do
  let(:habistone) { Habistone.new }

  describe 'Transforming census data' do
    let(:hab_census) { File.read('spec/data/census.json') }

    it 'Transforms to json matching the schema' do
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
