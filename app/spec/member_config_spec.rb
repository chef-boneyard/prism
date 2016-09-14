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
        config_response = double('config_response', body: 'supervisor_config')
        expect(RestClient).to receive(:get).with("http://1.2.3.4:9631/config").and_return(config_response)
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

  describe '#project_deps and #project_deps_onto' do
    it "returns a correct list of dependencies" do
      deps_from_config = [
        {
          "ident" => "pkg1",
          "deps" => [
            { "ident" => "pkg1_dep1", "deps" => [] },
            {
              "ident" => "pkg1_dep2",
              "deps" => [
                { "ident" => "pkg1_dep2_dep1", "deps" => []}
              ]
            },
          ]
        },
        { "ident" => "pkg2", "deps" => [] },
        { "ident" => "pkg3", "deps" => [] },
        {
          "ident" => "pkg4",
          "deps" => [
            { "ident" => "pkg4_dep1", "deps" => [] }
          ]
        }
      ]

      expect(member_config.project_deps(deps_from_config)).to eq(
        [
          "pkg1",
          "pkg1_dep1",
          "pkg1_dep2",
          "pkg1_dep2_dep1",
          "pkg2",
          "pkg3",
          "pkg4",
          "pkg4_dep1"
        ]
      )
    end
  end

  describe 'config schema validation' do
    let(:config_toml) { File.read('spec/data/config.toml') }

    it 'Transforms to json matching the schema' do
      config_json = member_config.refract(config_toml)
      expect(config_json.to_json).to match_response_schema('ring_config_schema')
    end
  end
end
