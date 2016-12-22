require "json-schema"
require "habistone"
require "json"
require "support/schema_matcher"
require "openssl"

describe Habistone do
  let(:habistone) { Habistone.new }

  describe "JSON Validation" do
    let(:config_response) { double("config_response", body: File.read("spec/data/config.toml")) }
    let(:census_response) { double("census_response", body: hab_census) }

    before do
      allow(RestClient).to receive(:get).with("http://172.17.0.2:9631/census").and_return(census_response)
      allow(RestClient).to receive(:get).with("http://172.17.0.2:9631/config").and_return(config_response)
      allow(RestClient).to receive(:get).with("http://172.17.0.2:9631/services/prism/default/config").and_return(config_response)
      allow(habistone).to receive(:detect_butterfly_existence)
      allow(habistone).to receive(:has_butterfly?).and_return(has_butterfly)

      Habistone::Config.supervisor_host = "172.17.0.2"
    end

    context "when the hab-sup is v0.14 or greater" do
      let(:has_butterfly) { true }
      let(:hab_census)    { File.read("spec/data/census-v0.14.json") }

      it "transforms to json matching the schema" do
        absorbed_data = habistone.absorb
        refracted_data = habistone.refract(absorbed_data)
        expect(refracted_data.to_json).to match_response_schema("ring_census")
      end
    end

    context "when the hab-sup is v0.13 or earlier" do
      let(:has_butterfly) { false }
      let(:hab_census)    { File.read("spec/data/census-v0.13.json") }

      it "Transforms to json matching the schema" do
        absorbed_data = habistone.absorb
        refracted_data = habistone.refract(absorbed_data)
        expect(refracted_data.to_json).to match_response_schema("ring_census")
      end
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
