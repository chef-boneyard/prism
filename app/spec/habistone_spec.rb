require 'json-schema'
require "habistone"
require 'json'
require 'support/schema_matcher'

describe Habistone do
  describe 'Transforming census data' do
    let(:hab_census) { '{"id":"d72234c1-a7bb-4a78-8c7a-a7b06e3f3c20","census_list":{"local_census":"prism.default","censuses":{"prism.default":{"me":"d72234c1-a7bb-4a78-8c7a-a7b06e3f3c20","population":{"d72234c1-a7bb-4a78-8c7a-a7b06e3f3c20":{"id":"d72234c1-a7bb-4a78-8c7a-a7b06e3f3c20","member_id":"960a49c5-5703-420f-991a-a9da48e50da5","hostname":"51bdbb264c0e","ip":"172.17.0.2","suitability":0,"port":null,"exposes":[],"leader":false,"follower":false,"data_init":false,"vote":null,"election":null,"needs_write":null,"initialized":false,"keep_me":true,"service":"prism","group":"default","alive":true,"suspect":false,"confirmed":false,"detached":false,"incarnation":{"counter":0}}},"in_event":false,"service":"prism","group":"default"}}},"me":{"id":"d72234c1-a7bb-4a78-8c7a-a7b06e3f3c20","member_id":"960a49c5-5703-420f-991a-a9da48e50da5","hostname":"51bdbb264c0e","ip":"172.17.0.2","suitability":0,"port":null,"exposes":[],"leader":false,"follower":false,"data_init":false,"vote":null,"election":null,"needs_write":null,"initialized":false,"keep_me":true,"service":"prism","group":"default","alive":true,"suspect":false,"confirmed":false,"detached":false,"incarnation":{"counter":0}},"local_census":{"me":"d72234c1-a7bb-4a78-8c7a-a7b06e3f3c20","population":{"d72234c1-a7bb-4a78-8c7a-a7b06e3f3c20":{"id":"d72234c1-a7bb-4a78-8c7a-a7b06e3f3c20","member_id":"960a49c5-5703-420f-991a-a9da48e50da5","hostname":"51bdbb264c0e","ip":"172.17.0.2","suitability":0,"port":null,"exposes":[],"leader":false,"follower":false,"data_init":false,"vote":null,"election":null,"needs_write":null,"initialized":false,"keep_me":true,"service":"prism","group":"default","alive":true,"suspect":false,"confirmed":false,"detached":false,"incarnation":{"counter":0}}},"in_event":false,"service":"prism","group":"default"},"minimum_quorum":false,"quorum":true,"leader":null}' }

    it 'Transforms to json matching the schema' do
      habistone = Habistone.new
      vis_census = habistone.refract(hab_census)
      expect(vis_census).to match_response_schema('ring_census')
    end
  end
end
