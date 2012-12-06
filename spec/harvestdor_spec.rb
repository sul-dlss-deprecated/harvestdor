require "spec_helper"

describe Harvestdor do

  context "#druid" do
    it "should return the druid part of an oai identifier" do
      Harvestdor.druid('oai:searchworks.stanford.edu/druid:foo').should == 'foo'
    end
    it "should work with OAI::Header as argument" do
      header = OAI::Header.new(nil)
      header.identifier = 'oai:searchworks.stanford.edu/druid:foo'
      Harvestdor.druid(header).should == 'foo'
    end
    it "should work with OAI::Record as argument" do
      oai_rec = OAI::Record.new(nil)
      header = OAI::Header.new(nil)
      header.identifier = 'oai:searchworks.stanford.edu/druid:foo'
      oai_rec.header = header
      Harvestdor.druid(oai_rec).should == 'foo'
    end
  end

end