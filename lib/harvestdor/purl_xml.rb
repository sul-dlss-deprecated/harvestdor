require 'nokogiri'

module Harvestdor
  # Mixin:  code to retrieve Purl public xml pieces
  
  RDF_NAMESPACE = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
  OAI_DC_NAMESPACE = 'http://www.openarchives.org/OAI/2.0/oai_dc/'
  MODS_NAMESPACE = 'http://www.loc.gov/mods/v3'

  # the MODS metadata for this fedora object, from the purl server
  # @param [String] druid e.g. ab123cd4567
  # @param [String] purl_url url for the purl server.  default is Harvestdor::PURL_DEFAULT
  # @return [Nokogiri::XML::Document] the MODS for the fedora object
  def self.mods druid, purl_url = Harvestdor::PURL_DEFAULT
    begin
      Nokogiri::XML(open("#{purl_url}/#{druid}.mods"),nil,'UTF-8')
    rescue OpenURI::HTTPError
      raise Harvestdor::Errors::MissingMods.new(druid)
    end
  end

  # the public xml for this fedora object, from the purl page
  # @param [String] druid e.g. ab123cd4567
  # @param [String] purl_url url for the purl server.  default is Harvestdor::PURL_DEFAULT
  # @return [Nokogiri::XML::Document] the public xml for the fedora object
  def self.public_xml druid, purl_url = Harvestdor::PURL_DEFAULT
    return druid if druid.instance_of?(Nokogiri::XML::Document)
    begin
      ng_doc = Nokogiri::XML(open("#{purl_url}/#{druid}.xml"))
      raise Harvestdor::Errors::MissingPublicXml.new(druid) if !ng_doc || ng_doc.children.empty?
      ng_doc 
    rescue OpenURI::HTTPError
      raise Harvestdor::Errors::MissingPurlPage.new(druid)
    end
  end

  # the contentMetadata for this fedora object, from the purl xml
  # @param [Object] object a String containing a druid (e.g. ab123cd4567), or 
  #  a Nokogiri::XML::Document containing the public_xml for an object
  # @param [String] purl_url url for the purl server.  default is Harvestdor::PURL_DEFAULT
  # @return [Nokogiri::XML::Document] the contentMetadata for the fedora object
  def self.content_metadata object, purl_url = Harvestdor::PURL_DEFAULT
    pub_xml_ng_doc = pub_xml(object, purl_url)
    begin
      # preserve namespaces, etc for the node
      ng_doc = Nokogiri::XML(pub_xml_ng_doc.root.xpath('/publicObject/contentMetadata').to_xml)
      raise Harvestdor::Errors::MissingContentMetadata.new(object.inspect) if !ng_doc || ng_doc.children.empty?
      ng_doc 
    rescue
      raise Harvestdor::Errors::MissingContentMetadata.new(object.inspect)
    end
  end

  # the identityMetadata for this fedora object, from the purl xml
  # @param [Object] object a String containing a druid (e.g. ab123cd4567), or 
  #  a Nokogiri::XML::Document containing the public_xml for an object
  # @param [String] purl_url url for the purl server.  default is Harvestdor::PURL_DEFAULT
  # @return [Nokogiri::XML::Document] the identityMetadata for the fedora object
  def self.identity_metadata object, purl_url = Harvestdor::PURL_DEFAULT
    pub_xml_ng_doc = pub_xml(object, purl_url)
    begin
      # preserve namespaces, etc for the node
      ng_doc = Nokogiri::XML(pub_xml_ng_doc.root.xpath('/publicObject/identityMetadata').to_xml)
      raise Harvestdor::Errors::MissingIdentityMetadata.new(object.inspect) if !ng_doc || ng_doc.children.empty?
      ng_doc 
    rescue
      raise Harvestdor::Errors::MissingIdentityMetadata.new(object.inspect)
    end
  end

  # the rightsMetadata for this fedora object, from the purl xml
  # @param [Object] object a String containing a druid (e.g. ab123cd4567), or 
  #  a Nokogiri::XML::Document containing the public_xml for an object
  # @param [String] purl_url url for the purl server.  default is Harvestdor::PURL_DEFAULT
  # @return [Nokogiri::XML::Document] the rightsMetadata for the fedora object
  def self.rights_metadata object, purl_url = Harvestdor::PURL_DEFAULT
    pub_xml_ng_doc = pub_xml(object, purl_url)
    begin
      # preserve namespaces, etc for the node
      ng_doc = Nokogiri::XML(pub_xml_ng_doc.root.xpath('/publicObject/rightsMetadata').to_xml)
      raise Harvestdor::Errors::MissingRightsMetadata.new(object.inspect) if !ng_doc || ng_doc.children.empty?
      ng_doc
    rescue
      raise Harvestdor::Errors::MissingRightsMetadata.new(object.inspect)
    end
  end

  # the RDF for this fedora object, from the purl xml
  # @param [Object] object a String containing a druid (e.g. ab123cd4567), or 
  #  a Nokogiri::XML::Document containing the public_xml for an object
  # @param [String] purl_url url for the purl server.  default is Harvestdor::PURL_DEFAULT
  # @return [Nokogiri::XML::Document] the RDF for the fedora object
  def self.rdf object, purl_url = Harvestdor::PURL_DEFAULT
    pub_xml_ng_doc = pub_xml(object, purl_url)
    begin
      # preserve namespaces, etc for the node
      ng_doc = Nokogiri::XML(pub_xml_ng_doc.root.xpath('/publicObject/rdf:RDF', {'rdf' => Harvestdor::RDF_NAMESPACE}).to_xml)
      raise Harvestdor::Errors::MissingRDF.new(object.inspect) if !ng_doc || ng_doc.children.empty?
      ng_doc
    rescue
      raise Harvestdor::Errors::MissingRDF.new(object.inspect)
    end
  end

  # the Dublin Core for this fedora object, from the purl xml
  # @param [Object] object a String containing a druid (e.g. ab123cd4567), or 
  #  a Nokogiri::XML::Document containing the public_xml for an object
  # @param [String] purl_url url for the purl server.  default is Harvestdor::PURL_DEFAULT
  # @return [Nokogiri::XML::Document] the dc for the fedora object
  def self.dc object, purl_url = Harvestdor::PURL_DEFAULT
    pub_xml_ng_doc = pub_xml(object, purl_url)
    begin
      # preserve namespaces, etc for the node
      ng_doc = Nokogiri::XML(pub_xml_ng_doc.root.xpath('/publicObject/dc:dc', {'dc' => Harvestdor::OAI_DC_NAMESPACE}).to_xml(:encoding => 'utf-8'))
      raise Harvestdor::Errors::MissingDC.new(object.inspect) if !ng_doc || ng_doc.children.empty?
      ng_doc
    rescue
      raise Harvestdor::Errors::MissingDC.new(object.inspect)
    end
  end


  class Client
    
    # the public xml for this fedora object, from the purl server
    # @param [String] druid e.g. ab123cd4567, in the purl url
    # @return [Nokogiri::XML::Document] the MODS metadata for the fedora object
    def mods druid
      Harvestdor.mods(druid, config.purl)
    end

    # the public xml for this fedora object, from the purl xml
    # @param [String] druid e.g. ab123cd4567, in the purl url
    # @return [Nokogiri::XML::Document] the public xml for the fedora object
    def public_xml druid
      Harvestdor.public_xml(druid, config.purl)
    end

    # the contentMetadata for this fedora object, from the purl xml
    # @param [Object] object a String containing a druid (e.g. ab123cd4567), or 
    #  a Nokogiri::XML::Document containing the public_xml for an object
    # @return [Nokogiri::XML::Document] the contentMetadata for the fedora object
    def content_metadata object
      Harvestdor.content_metadata(object, config.purl)
    end

    # the identityMetadata for this fedora object, from the purl xml
    # @param [Object] object a String containing a druid (e.g. ab123cd4567), or 
    #  a Nokogiri::XML::Document containing the public_xml for an object
    # @return [Nokogiri::XML::Document] the identityMetadata for the fedora object
    def identity_metadata object
      Harvestdor.identity_metadata(object, config.purl)
    end

    # the rightsMetadata for this fedora object, from the purl xml
    # @param [Object] object a String containing a druid (e.g. ab123cd4567), or 
    #  a Nokogiri::XML::Document containing the public_xml for an object
    # @return [Nokogiri::XML::Document] the rightsMetadata for the fedora object
    def rights_metadata object
      Harvestdor.rights_metadata(object, config.purl)
    end

    # the RDF for this fedora object, from the purl xml
    # @param [Object] object a String containing a druid (e.g. ab123cd4567), or 
    #  a Nokogiri::XML::Document containing the public_xml for an object
    # @return [Nokogiri::XML::Document] the RDF for the fedora object
    def rdf object
      Harvestdor.rdf(object, config.purl)
    end

    # the Dublin Core for this fedora object, from the purl xml
    # @param [Object] object a String containing a druid (e.g. ab123cd4567), or 
    #  a Nokogiri::XML::Document containing the public_xml for an object
    # @return [Nokogiri::XML::Document] the dc for the fedora object
    def dc object
      Harvestdor.dc(object, config.purl)
    end
    
  end # class Client

  protected #--------------------------------------------
  
  # @param [Object] object a String containing a druid (e.g. ab123cd4567), or 
  #  a Nokogiri::XML::Document containing the public_xml for an object
  # @param [String] purl_url url for the purl server.  default is Harvestdor::PURL_DEFAULT
  # @return [Nokogiri::XML::Document] the public xml for a DOR object
  def self.pub_xml(object, purl_url = Harvestdor::PURL_DEFAULT)
    case 
      when object.instance_of?(String)
        # it's a druid
        pub_xml_ng_doc = Harvestdor.public_xml(object, purl_url)
      when object.instance_of?(Nokogiri::XML::Document)
        pub_xml_ng_doc = object
      else
        raise "expected String or Nokogiri::XML::Document for first argument, got #{object.class}"
    end
    pub_xml_ng_doc    
  end

end # module Harvestdor