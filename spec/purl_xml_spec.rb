require "spec_helper"

# these are Integration specs!  They do go out to the purl page.
describe Harvestdor::Client do

  before(:all) do
    @druid = 'bb375wb8869'
    @purl = 'http://purl-test.stanford.edu'
    @id_md_xml = "<identityMetadata><objectId>druid:#{@druid}</objectId></identityMetadata>"
    @cntnt_md_xml = "<contentMetadata type='image' objectId='#{@druid}'>foo</contentMetadata>"
    @rights_md_xml = "<rightsMetadata><access type=\"discover\"><machine><world>bar</world></machine></access></rightsMetadata>"
    @rdf_xml = "<rdf:RDF xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'><rdf:Description rdf:about=\"info:fedora/druid:#{@druid}\">relationship!</rdf:Description></rdf:RDF>"
    @dc_xml = "<oai_dc:dc xmlns:oai_dc='#{Harvestdor::OAI_DC_NAMESPACE}'><oai_dc:title>hoo ha</oai_dc:title</oai_dc:dc>"
    @pub_xml = "<publicObject id='druid:#{@druid}'>#{@id_md_xml}#{@cntnt_md_xml}#{@rights_md_xml}#{@rdf_xml}#{@dc_xml}</publicObject>"
    @ng_pub_xml = Nokogiri::XML(@pub_xml)      
  end
  
  it "raises Harvestdor::Errors::MissingPurlPage if there is no purl page for the druid" do
    druid = 'oo134oo1010'
    expect { Harvestdor.public_xml(druid, @purl) }.to raise_error(Harvestdor::Errors::MissingPurlPage)
  end
  context "public xml methods called w druids" do
    it "#public_xml retrieves entire public xml as a Nokogiri::XML::Document" do
      px = Harvestdor.public_xml(@druid, @purl)
      px.should be_kind_of(Nokogiri::XML::Document)
      px.root.name.should == 'publicObject'
      px.root.attributes['id'].text.should == "druid:#{@druid}"
    end
    it "#content_metadata returns a Nokogiri::XML::Document from the public xml" do
      cm = Harvestdor.content_metadata(@druid, @purl)
      cm.should be_kind_of(Nokogiri::XML::Document)
      cm.root.name.should == 'contentMetadata'
      cm.root.attributes['objectId'].text.should == @druid
    end
    it "#identity_metadata returns a Nokogiri::XML::Document from the public xml" do
      im = Harvestdor.identity_metadata(@druid, @purl)
      im.should be_kind_of(Nokogiri::XML::Document)
      im.root.name.should == 'identityMetadata'
      im.root.xpath('objectId').text.should == "druid:#{@druid}"
    end
    it "#rights_metadata returns a Nokogiri::XML::Document from the public xml" do
      rm = Harvestdor.rights_metadata(@druid, @purl)
      rm.should be_kind_of(Nokogiri::XML::Document)
      rm.root.name.should == 'rightsMetadata'
    end
    it "#rdf returns a Nokogiri::XML::Document from the public xml" do
      rdf = Harvestdor.rdf(@druid, @purl)
      rdf.should be_kind_of(Nokogiri::XML::Document)
      rdf.root.name.should == 'RDF'
      rdf.root.namespace.href.should == Harvestdor::RDF_NAMESPACE
    end
    it "#dc returns a Nokogiri::XML::Document from the public xml" do
      dc = Harvestdor.dc(@druid, @purl)
      dc.should be_kind_of(Nokogiri::XML::Document)
      dc.root.name.should == 'dc'
      dc.root.namespace.href.should == Harvestdor::OAI_DC_NAMESPACE
    end
  end # public xml methods called with druids
  
  context "public xml methods called with public xml as Nokogiri::XML::Document" do
    it "#content_metadata returns a Nokogiri::XML::Document from the public xml" do
      cm = Harvestdor.content_metadata(@ng_pub_xml)
      cm.should be_kind_of(Nokogiri::XML::Document)
      cm.root.name.should == 'contentMetadata'
      cm.root.attributes['objectId'].text.should == @druid
    end
    it "#identity_metadata returns a Nokogiri::XML::Document from the public xml" do
      im = Harvestdor.identity_metadata(@ng_pub_xml)
      im.should be_kind_of(Nokogiri::XML::Document)
      im.root.name.should == 'identityMetadata'
      im.root.xpath('objectId').text.should == "druid:#{@druid}"
    end
    it "#rights_metadata returns a Nokogiri::XML::Document from the public xml" do
      rm = Harvestdor.rights_metadata(@ng_pub_xml)
      rm.should be_kind_of(Nokogiri::XML::Document)
      rm.root.name.should == 'rightsMetadata'
    end
    it "#rdf returns a Nokogiri::XML::Document from the public xml" do
      rdf = Harvestdor.rdf(@ng_pub_xml)
      rdf.should be_kind_of(Nokogiri::XML::Document)
      rdf.root.name.should == 'RDF'
      rdf.root.namespace.href.should == Harvestdor::RDF_NAMESPACE
    end
    it "#dc returns a Nokogiri::XML::Document from the public xml" do
      dc = Harvestdor.dc(@ng_pub_xml)
      dc.should be_kind_of(Nokogiri::XML::Document)
      dc.root.name.should == 'dc'
      dc.root.namespace.href.should == Harvestdor::OAI_DC_NAMESPACE
    end
  end # public xml methods called with public xml as Nokogiri::XML::Document

  context "public xml methods called with unknown object type" do
    before(:all) do
      @errmsg = "expected String or Nokogiri::XML::Document for first argument, got Array"
    end
    it "#content_metadata raises error for unknown type" do
      expect { Harvestdor.content_metadata(Array.new)}.to raise_error(RuntimeError, "#{@errmsg}")
    end
    it "#identity_metadata raises error for unknown type" do
      expect { Harvestdor.identity_metadata(Array.new)}.to raise_error(RuntimeError, "#{@errmsg}")
    end
    it "#rights_metadata raises error for unknown type" do
      expect { Harvestdor.rights_metadata(Array.new)}.to raise_error(RuntimeError, "#{@errmsg}")
    end
    it "#rdf raises error for unknown type" do
      expect { Harvestdor.rdf(Array.new)}.to raise_error(RuntimeError, "#{@errmsg}")
    end
    it "#dc raises error for unknown type" do
      expect { Harvestdor.dc(Array.new)}.to raise_error(RuntimeError, "#{@errmsg}")
    end
  end

  it "#mods returns a Nokogiri::XML::Document from the purl mods" do
    x = Harvestdor.mods(@druid, @purl)
    x.should be_kind_of(Nokogiri::XML::Document)
    x.root.name.should == 'mods'
    x.root.namespace.href.should == Harvestdor::MODS_NAMESPACE
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
    it "mods calls Harvestdor.mods with config.purl" do
      Harvestdor.should_receive(:mods).with(@druid, @client.config.purl)
      @client.mods(@druid)
    end
    it "public xml pieces methods should work with Nokogiri::XML::Document arg" do
      @client.content_metadata(@ng_pub_xml).should be_kind_of(Nokogiri::XML::Document)
      @client.identity_metadata(@ng_pub_xml).should be_kind_of(Nokogiri::XML::Document)
      @client.rights_metadata(@ng_pub_xml).should be_kind_of(Nokogiri::XML::Document)
      @client.rdf(@ng_pub_xml).should be_kind_of(Nokogiri::XML::Document)
      @client.dc(@ng_pub_xml).should be_kind_of(Nokogiri::XML::Document)
    end
  end
end