require 'json-schema'
require 'habistone'
require 'json'
require 'support/schema_matcher'
require 'openssl'

describe Habistone do
  let(:member_config) { Habistone::MemberConfig.new('1.2.3.4') }

  describe '#get_config' do
    context "when the HTTP call is successful" do
      it "makes the HTTP call, refracts the data, and returns it" do
        expect(RestClient).to receive(:get).with("http://1.2.3.4:9631/config").and_return("supervisor_config")
        expect(member_config).to receive(:refract).with("supervisor_config").and_return("refracted_config")
        expect(member_config.get_config).to eq("refracted_config")
      end
    end

    context "when the HTTP call fails with a response" do
      it "returns a error hash with a status and message" do
        response = double('response', body: 'error body')
        exception = RestClient::ExceptionWithResponse.new(response)
        expect(RestClient).to receive(:get).with("http://1.2.3.4:9631/config").and_raise(exception)
        expect(exception).to receive(:http_code).and_return(500)
        expect(member_config.get_config).to eq({ error: { status: 500, message: 'error body' } })
      end
    end

    context "when the HTTP call fails with no response" do
      it "returns a error hash with a status and message" do
        expect(RestClient).to receive(:get).with("http://1.2.3.4:9631/config").and_raise(RuntimeError.new("plain exception"))
        expect(member_config.get_config).to eq({ error: { message: 'plain exception'} })
      end
    end
  end

  describe 'Transforming config data' do
    let(:config_toml) { File.read('spec/data/config.toml') }

    it 'Transforms to json matching the schema' do
      config_json = member_config.refract(config_toml)
      expect(config_json).to match_response_schema('ring_config_schema')
    end
  end
end
