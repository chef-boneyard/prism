require 'json-schema'
require "ring_walker"
require 'json'
require 'support/schema_matcher'

describe Habistone do
  describe 'Retrieving gossip data' do
    #add more members to this
    let(:hab_gossip) {File.read("spec/data/gossip.json")}

    it 'Parses members from gossip list' do

    end
  end
end
