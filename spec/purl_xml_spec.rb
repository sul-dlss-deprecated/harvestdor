require "spec_helper"

describe Harvestdor::Client do

  before(:all) do
    @druid = 'bb375wb8869'
    @purl = 'http://purl-test.stanford.edu'
  end
  it "raises Harvestdor::Errors::MissingPurlPage if there is no purl page for the druid" do
    druid = 'oo134oo1010'
    expect { Harvestdor.public_xml(druid, @purl) }.to raise_error(Harvestdor::Errors::MissingPurlPage)
  end
  it "#public_xml retrieves entire public xml as a Nokogiri::XML::Document" do
    px = Harvestdor.public_xml(@druid, @purl)
    px.should be_kind_of(Nokogiri::XML::Document)
    px.root.name.should == 'publicObject'
    px.root.attributes['id'].text.should == "druid:#{@druid}"
  end
  it "#content_metadata retrieves contentMetadata as a Nokogiri::XML::Document" do
    cm = Harvestdor.content_metadata(@druid, @purl)
    cm.should be_kind_of(Nokogiri::XML::Document)
    cm.root.name.should == 'contentMetadata'
    cm.root.attributes['objectId'].text.should == @druid
  end
  it "#identity_metadata retrieves identityMetadata as a Nokogiri::XML::Document" do
    im = Harvestdor.identity_metadata(@druid, @purl)
    im.should be_kind_of(Nokogiri::XML::Document)
    im.root.name.should == 'identityMetadata'
    im.root.xpath('objectId').text.should == "druid:#{@druid}"
  end
  it "#rights_metadata retrieves rightsMetadata as a Nokogiri::XML::Document" do
    rm = Harvestdor.rights_metadata(@druid, @purl)
    rm.should be_kind_of(Nokogiri::XML::Document)
    rm.root.name.should == 'rightsMetadata'
  end
  it "#rdf retrieves rdf as a Nokogiri::XML::Document" do
    rdf = Harvestdor.rdf(@druid, @purl)
    rdf.should be_kind_of(Nokogiri::XML::Document)
    rdf.root.name.should == 'RDF'
    rdf.root.namespace.href.should == Harvestdor::RDF_NAMESPACE
  end
  it "#dc retrieves dc as a Nokogiri::XML::Document" do
    dc = Harvestdor.dc(@druid, @purl)
    dc.should be_kind_of(Nokogiri::XML::Document)
    dc.root.name.should == 'dc'
    dc.root.namespace.href.should == Harvestdor::OAI_DC_NAMESPACE
  end

  context "Harvestdor:Client" do
    before(:all) do
      @client = Harvestdor::Client.new({:purl_url => 'http://thisone.org'})
      @druid = 'bb375wb8869'
    end
    it "public_xml calls Harvestdor.public_xml with config.purl" do
      Harvestdor.should_receive(:public_xml).with(@druid, @client.config.purl)
      @client.public_xml(@druid)
    end
    it "content_metadata calls Harvestdor.content_metadata with config.purl" do
      Harvestdor.should_receive(:content_metadata).with(@druid, @client.config.purl)
      @client.content_metadata(@druid)
    end
    it "identity_metadata calls Harvestdor.identity_metadata with config.purl" do
      Harvestdor.should_receive(:identity_metadata).with(@druid, @client.config.purl)
      @client.identity_metadata(@druid)
    end
    it "rights_metadata calls Harvestdor.rights_metadata with config.purl" do
      Harvestdor.should_receive(:rights_metadata).with(@druid, @client.config.purl)
      @client.rights_metadata(@druid)
    end
    it "rdf calls Harvestdor.rdf with config.purl" do
      Harvestdor.should_receive(:rdf).with(@druid, @client.config.purl)
      @client.rdf(@druid)
    end
    it "dc calls Harvestdor.dc with config.purl" do
      Harvestdor.should_receive(:dc).with(@druid, @client.config.purl)
      @client.dc(@druid)
    end
  end

end