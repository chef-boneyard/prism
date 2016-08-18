require 'json-schema'
require "habistone"
require 'json'
require 'support/schema_matcher'

describe Habistone do
  describe 'Transforming census data' do
    let(:hab_census) {File.read("spec/data/census.json")}

    it 'Transforms to json matching the schema' do
      habistone = Habistone.new
      vis_census = habistone.refract(hab_census)
      expect(vis_census).to match_response_schema('ring_census')
    end
  end
end
