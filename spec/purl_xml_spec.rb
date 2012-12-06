require "spec_helper"

describe Harvestdor::Client do

  context "information from purl pages" do
    before(:all) do
      @client = Harvestdor::Client.new
      @druid = 'bb375wb8869'
    end
    it "raises Harvestdor::Errors::MissingPurlPage if there is no purl page for the druid" do
      druid = 'oo666oo6666'
      expect { @client.content_metadata(druid) }.to raise_error(Harvestdor::Errors::MissingPurlPage)
    end
    it "public_xml retrieves entire public xml as a Nokogiri::XML::Document" do
      px = @client.public_xml(@druid)
      px.should be_kind_of(Nokogiri::XML::Document)
      px.root.name.should == 'publicObject'
      px.root.attributes['id'].text.should == "druid:#{@druid}"
    end
    it "content_metadata retrieves contentMetadata as a Nokogiri::XML::Document" do
      cm = @client.content_metadata(@druid)
      cm.should be_kind_of(Nokogiri::XML::Document)
      cm.root.name.should == 'contentMetadata'
      cm.root.attributes['objectId'].text.should == @druid
    end
    it "identity_metadata retrieves identityMetadata as a Nokogiri::XML::Document" do
      im = @client.identity_metadata(@druid)
      im.should be_kind_of(Nokogiri::XML::Document)
      im.root.name.should == 'identityMetadata'
      im.root.xpath('objectId').text.should == "druid:#{@druid}"
    end
    it "rights_metadata retrieves rightsMetadata as a Nokogiri::XML::Document" do
      rm = @client.rights_metadata(@druid)
      rm.should be_kind_of(Nokogiri::XML::Document)
      rm.root.name.should == 'rightsMetadata'
    end
    it "rdf retrieves rdf as a Nokogiri::XML::Document" do
      rdf = @client.rdf(@druid)
      rdf.should be_kind_of(Nokogiri::XML::Document)
      rdf.root.name.should == 'RDF'
      rdf.root.namespace.href.should == Harvestdor::RDF_NAMESPACE
    end
    it "dc retrieves dc as a Nokogiri::XML::Document" do
      dc = @client.dc(@druid)
      dc.should be_kind_of(Nokogiri::XML::Document)
      dc.root.name.should == 'dc'
      dc.root.namespace.href.should == Harvestdor::OAI_DC_NAMESPACE
    end
  end

end