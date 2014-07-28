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
    @fake_druid = 'oo000oo0000'     
  end
  
  it "#mods returns a Nokogiri::XML::Document from the purl mods" do
    VCR.use_cassette('purl_mods') do
      x = Harvestdor.mods(@druid, @purl)
      expect(x).to be_kind_of(Nokogiri::XML::Document)
      expect(x.root.name).to eql('mods')
      expect(x.root.namespace.href).to eql(Harvestdor::MODS_NAMESPACE)
    end
  end    

  context "#public_xml" do
    it "#public_xml retrieves entire public xml as a Nokogiri::XML::Document when called with druid" do
      VCR.use_cassette('public_xml') do
        px = Harvestdor.public_xml(@druid, @purl)
        expect(px).to be_kind_of(Nokogiri::XML::Document)
        expect(px.root.name).to eql('publicObject')
        expect(px.root.attributes['id'].text).to eql("druid:#{@druid}")
      end
    end
    it "raises Harvestdor::Errors::MissingPurlPage if there is no purl page for the druid" do
      VCR.use_cassette('missing_purl') do
        expect { Harvestdor.public_xml(@fake_druid, @purl) }.to raise_error(Harvestdor::Errors::MissingPurlPage)
      end
    end
    it "raises Harvestdor::Errors::MissingPublicXML if purl page returns nil document" do
      expect_any_instance_of(URI::HTTP).to receive(:open).and_return(nil)
      expect { Harvestdor.public_xml(@fake_druid, @purl) }.to raise_error(Harvestdor::Errors::MissingPublicXml)
    end
  end
  
  context "#pub_xml" do
    it "retrieves public_xml via fetch when first arg is a druid" do
      expect(Harvestdor).to receive(:public_xml).with(@druid, @purl)
      Harvestdor.pub_xml(@druid, @purl)
    end
    it "returns the first arg if it is a Nokogiri::XML::Document" do
      expect(Harvestdor.pub_xml(@ng_pub_xml)).to eql(@ng_pub_xml)
    end
    it "raises error for unknown arg type" do
      expect { Harvestdor.pub_xml(Array.new)}.to raise_error(RuntimeError, "expected String or Nokogiri::XML::Document for first argument, got Array")
    end
  end
  
  context "#content_metadata" do
    it "returns a Nokogiri::XML::Document from the public xml fetched with druid" do
      VCR.use_cassette('content_metadata') do
        cm = Harvestdor.content_metadata(@druid, @purl)
        expect(cm).to be_kind_of(Nokogiri::XML::Document)
        expect(cm.root.name).to eql('contentMetadata')
        expect(cm.root.attributes['objectId'].text).to eql(@druid)
      end
    end
    it "returns a Nokogiri::XML::Document from passed Nokogiri::XML::Document and does no fetch" do
      cm = Harvestdor.content_metadata(@ng_pub_xml)
      expect(cm).to be_kind_of(Nokogiri::XML::Document)
      expect(cm.root.name).to eql('contentMetadata')
      expect(cm.root.attributes['objectId'].text).to eql(@druid)
    end
    it "raises MissingContentMetadata error if there is no contentMetadata in the public_xml for the druid" do
      pub_xml = "<publicObject id='druid:#{@druid}'>#{@id_md_xml}#{@rights_md_xml}</publicObject>"
      expect { Harvestdor.content_metadata(Nokogiri::XML(pub_xml)) }.to raise_error(Harvestdor::Errors::MissingContentMetadata)
    end 
  end
  
  context "#identity_metadata" do
    it "returns a Nokogiri::XML::Document from the public xml fetched with druid" do
      VCR.use_cassette('identity_metadata') do
        im = Harvestdor.identity_metadata(@druid, @purl)
        expect(im).to be_kind_of(Nokogiri::XML::Document)
        expect(im.root.name).to eql('identityMetadata')
        expect(im.root.xpath('objectId').text).to eql("druid:#{@druid}")
      end
    end
    it "returns a Nokogiri::XML::Document from passed Nokogiri::XML::Document and does no fetch" do
      expect_any_instance_of(URI::HTTP).not_to receive(:open)
      im = Harvestdor.identity_metadata(@ng_pub_xml)
      expect(im).to be_kind_of(Nokogiri::XML::Document)
      expect(im.root.name).to eql('identityMetadata')
      expect(im.root.xpath('objectId').text).to eql("druid:#{@druid}")
    end
    it "raises MissingIdentityMetadata error if there is no identityMetadata in the public_xml for the druid" do
      pub_xml = "<publicObject id='druid:#{@druid}'>#{@cntnt_md_xml}#{@rights_md_xml}</publicObject>"
      expect { Harvestdor.identity_metadata(Nokogiri::XML(pub_xml)) }.to raise_error(Harvestdor::Errors::MissingIdentityMetadata)
    end  
  end
  
  context "#rights_metadata" do
    it "#rights_metadata returns a Nokogiri::XML::Document from the public xml fetched with druid" do
      VCR.use_cassette('rights_metadata') do
        rm = Harvestdor.rights_metadata(@druid, @purl)
        expect(rm).to be_kind_of(Nokogiri::XML::Document)
        expect(rm.root.name).to eql('rightsMetadata')
      end
    end
    it "returns a Nokogiri::XML::Document from passed Nokogiri::XML::Document and does no fetch" do
      expect_any_instance_of(URI::HTTP).not_to receive(:open)
      rm = Harvestdor.rights_metadata(@ng_pub_xml)
      expect(rm).to be_kind_of(Nokogiri::XML::Document)
      expect(rm.root.name).to eql('rightsMetadata')
    end
    it "raises MissingRightsMetadata error if there is no identityMetadata in the public_xml for the druid" do
      pub_xml = "<publicObject id='druid:#{@druid}'>#{@cntnt_md_xml}#{@id_md_xml}</publicObject>"
      expect { Harvestdor.rights_metadata(Nokogiri::XML(pub_xml)) }.to raise_error(Harvestdor::Errors::MissingRightsMetadata)
    end  
  end
  
  context "#rdf" do
    it "returns a Nokogiri::XML::Document from the public xml fetched with druid" do
      VCR.use_cassette('rdf') do
        rdf = Harvestdor.rdf(@druid, @purl)
        expect(rdf).to be_kind_of(Nokogiri::XML::Document)
        expect(rdf.root.name).to eql('RDF')
        expect(rdf.root.namespace.href).to eql(Harvestdor::RDF_NAMESPACE)
      end
    end
    it "returns a Nokogiri::XML::Document from passed Nokogiri::XML::Document and does no fetch" do
      expect_any_instance_of(URI::HTTP).not_to receive(:open)
      rdf = Harvestdor.rdf(@ng_pub_xml)
      expect(rdf).to be_kind_of(Nokogiri::XML::Document)
      expect(rdf.root.name).to eql('RDF')
      expect(rdf.root.namespace.href).to eql(Harvestdor::RDF_NAMESPACE)
    end
    it "raises MissingRDF error if there is no RDF in the public_xml for the druid" do
      pub_xml = "<publicObject id='druid:#{@druid}'>#{@cntnt_md_xml}#{@id_md_xml}</publicObject>"
      expect { Harvestdor.rdf(Nokogiri::XML(pub_xml)) }.to raise_error(Harvestdor::Errors::MissingRDF)
    end  
  end
  
  context "#dc" do
    it "returns a Nokogiri::XML::Document from the public xml fetched with druid" do
      VCR.use_cassette('dc') do
        dc = Harvestdor.dc(@druid, @purl)
        expect(dc).to be_kind_of(Nokogiri::XML::Document)
        expect(dc.root.name).to eql('dc')
        expect(dc.root.namespace.href).to eql(Harvestdor::OAI_DC_NAMESPACE)
      end
    end
    it "returns a Nokogiri::XML::Document from passed Nokogiri::XML::Document and does no fetch" do
      expect_any_instance_of(URI::HTTP).not_to receive(:open)
      dc = Harvestdor.dc(@ng_pub_xml)
      expect(dc).to be_kind_of(Nokogiri::XML::Document)
      expect(dc.root.name).to eql('dc')
      expect(dc.root.namespace.href).to eql(Harvestdor::OAI_DC_NAMESPACE)
    end
    it "raises MissingDC error if there is no DC in the public_xml for the druid" do
      pub_xml = "<publicObject id='druid:#{@druid}'>#{@cntnt_md_xml}#{@id_md_xml}</publicObject>"
      expect { Harvestdor.dc(Nokogiri::XML(pub_xml)) }.to raise_error(Harvestdor::Errors::MissingDC)
    end  
  end
  
  context "Harvestdor:Client calls methods with config.purl" do
    before(:all) do
      @client = Harvestdor::Client.new({:purl_url => 'http://thisone.org'})
      @druid = 'bb375wb8869'
    end
    it "public_xml calls Harvestdor.public_xml with config.purl" do
      expect(Harvestdor).to receive(:public_xml).with(@druid, @client.config.purl)
      @client.public_xml(@druid)
    end
    it "content_metadata calls Harvestdor.content_metadata with config.purl" do
      expect(Harvestdor).to receive(:content_metadata).with(@druid, @client.config.purl)
      @client.content_metadata(@druid)
    end
    it "identity_metadata calls Harvestdor.identity_metadata with config.purl" do
      expect(Harvestdor).to receive(:identity_metadata).with(@druid, @client.config.purl)
      @client.identity_metadata(@druid)
    end
    it "rights_metadata calls Harvestdor.rights_metadata with config.purl" do
      expect(Harvestdor).to receive(:rights_metadata).with(@druid, @client.config.purl)
      @client.rights_metadata(@druid)
    end
    it "rdf calls Harvestdor.rdf with config.purl" do
      expect(Harvestdor).to receive(:rdf).with(@druid, @client.config.purl)
      @client.rdf(@druid)
    end
    it "dc calls Harvestdor.dc with config.purl" do
      expect(Harvestdor).to receive(:dc).with(@druid, @client.config.purl)
      @client.dc(@druid)
    end
    it "mods calls Harvestdor.mods with config.purl" do
      expect(Harvestdor).to receive(:mods).with(@druid, @client.config.purl)
      @client.mods(@druid)
    end
    it "methods for parts of public_xml should work with Nokogiri::XML::Document arg (and not fetch)" do
      expect_any_instance_of(URI::HTTP).not_to receive(:open)
      expect(@client.content_metadata(@ng_pub_xml)).to be_kind_of(Nokogiri::XML::Document)
      expect(@client.identity_metadata(@ng_pub_xml)).to be_kind_of(Nokogiri::XML::Document)
      expect(@client.rights_metadata(@ng_pub_xml)).to be_kind_of(Nokogiri::XML::Document)
      expect(@client.rdf(@ng_pub_xml)).to be_kind_of(Nokogiri::XML::Document)
      expect(@client.dc(@ng_pub_xml)).to be_kind_of(Nokogiri::XML::Document)
    end
  end
end