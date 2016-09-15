require "json-schema"
require "habistone"
require "json"
require "support/schema_matcher"
require "openssl"

describe Habistone do
  let(:habistone) { Habistone.new }

  describe "JSON Validation" do
    let(:hab_census) { File.read("spec/data/census.json") }
    let(:sup_config) { File.read("spec/data/config.toml") }

    it "Transforms to json matching the schema" do
      census_response = double("census_response", body: hab_census)
      config_response = double("config_response", body: sup_config)
      expect(RestClient).to receive(:get).with("http://172.17.0.2:9631/census").and_return(census_response)
      expect(RestClient).to receive(:get).with("http://172.17.0.2:9631/config").and_return(config_response)

      Habistone::Config.supervisor_host = "172.17.0.2"
      absorbed_data = habistone.absorb
      refracted_data = habistone.refract(absorbed_data)

      expect(refracted_data.to_json).to match_response_schema("ring_census")
    end
  end

  describe '#ssl_verify_mode' do
    it "Disables SSL verification when the config is set to false" do
      Habistone::Config.ssl_verification_enabled = false
      expect(habistone.send(:ssl_verify_mode)).to eq(OpenSSL::SSL::VERIFY_NONE)
    end

    it "Enables SSL verification when the config is set to true" do
      Habistone::Config.ssl_verification_enabled = true
      expect(habistone.send(:ssl_verify_mode)).to eq(OpenSSL::SSL::VERIFY_PEER)
    end
  end
end
