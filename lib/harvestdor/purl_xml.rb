require 'nokogiri'

module Harvestdor
  # Mixin:  code to retrieve Purl public xml pieces
  
  RDF_NAMESPACE = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
  OAI_DC_NAMESPACE = 'http://www.openarchives.org/OAI/2.0/oai_dc/'
  MODS_NAMESPACE = 'http://www.loc.gov/mods/v3'

  # the MODS metadata for this fedora object, from the purl server
  # @param [String] druid, e.g. ab123cd4567
  # @param [String] purl_url url for the purl server.  default is Harvestdor::PURL_DEFAULT
  # @return [Nokogiri::XML::Document] the MODS for the fedora object
  def self.mods druid, purl_url = Harvestdor::PURL_DEFAULT
    begin
      Nokogiri::XML(open("#{purl_url}/#{druid}.mods"))
    rescue OpenURI::HTTPError
      raise Harvestdor::Errors::MissingMods.new(druid)
    end
  end

  # the public xml for this fedora object, from the purl page
  # @param [String] druid, e.g. ab123cd4567
  # @param [String] purl_url url for the purl server.  default is Harvestdor::PURL_DEFAULT
  # @return [Nokogiri::XML::Document] the public xml for the fedora object
  def self.public_xml druid, purl_url = Harvestdor::PURL_DEFAULT
    begin
      Nokogiri::XML(open("#{purl_url}/#{druid}.xml"))
    rescue OpenURI::HTTPError
      raise Harvestdor::Errors::MissingPurlPage.new(druid)
    rescue
      raise Harvestdor::Errors::MissingPublicXml.new(druid)
    end
  end

  # the contentMetadata for this fedora object, from the purl xml
  # @param [String] druid, e.g. ab123cd4567
  # @param [String] purl_url url for the purl server.  default is Harvestdor::PURL_DEFAULT
  # @return [Nokogiri::XML::Document] the contentMetadata for the fedora object
  def self.content_metadata druid, purl_url = Harvestdor::PURL_DEFAULT
    xml = Harvestdor.public_xml(druid, purl_url)
    begin
      # preserve namespaces, etc for the node
      Nokogiri::XML(xml.root.xpath('/publicObject/contentMetadata').to_xml)
    rescue
      raise Harvestdor::Errors::MissingContentMetadata.new(druid)
    end
  end

  # the identityMetadata for this fedora object, from the purl xml
  # @param [String] druid, e.g. ab123cd4567
  # @param [String] purl_url url for the purl server.  default is Harvestdor::PURL_DEFAULT
  # @return [Nokogiri::XML::Document] the identityMetadata for the fedora object
  def self.identity_metadata druid, purl_url = Harvestdor::PURL_DEFAULT
    xml = Harvestdor.public_xml(druid, purl_url)
    begin
      # preserve namespaces, etc for the node
      Nokogiri::XML(xml.root.xpath('/publicObject/identityMetadata').to_xml)
    rescue
      raise Harvestdor::Errors::MissingIdentityMetadata.new(druid)
    end
  end

  # the rightsMetadata for this fedora object, from the purl xml
  # @param [String] druid, e.g. ab123cd4567
  # @param [String] purl_url url for the purl server.  default is Harvestdor::PURL_DEFAULT
  # @return [Nokogiri::XML::Document] the rightsMetadata for the fedora object
  def self.rights_metadata druid, purl_url = Harvestdor::PURL_DEFAULT
    xml = Harvestdor.public_xml(druid, purl_url)
    begin
      # preserve namespaces, etc for the node
      Nokogiri::XML(xml.root.xpath('/publicObject/rightsMetadata').to_xml)
    rescue
      raise Harvestdor::Errors::MissingRightsMetadata.new(druid)
    end
  end

  # the RDF for this fedora object, from the purl xml
  # @param [String] druid, e.g. ab123cd4567
  # @param [String] purl_url url for the purl server.  default is Harvestdor::PURL_DEFAULT
  # @return [Nokogiri::XML::Document] the RDF for the fedora object
  def self.rdf druid, purl_url = Harvestdor::PURL_DEFAULT
    xml = Harvestdor.public_xml(druid, purl_url)
    begin
      # preserve namespaces, etc for the node
      Nokogiri::XML(xml.root.xpath('/publicObject/rdf:RDF', {'rdf' => Harvestdor::RDF_NAMESPACE}).to_xml)
    rescue
      raise Harvestdor::Errors::MissingRDF.new(druid)
    end
  end

  # the Dublin Core for this fedora object, from the purl xml
  # @param [String] druid, e.g. ab123cd4567
  # @param [String] purl_url url for the purl server.  default is Harvestdor::PURL_DEFAULT
  # @return [Nokogiri::XML::Document] the dc for the fedora object
  def self.dc druid, purl_url = Harvestdor::PURL_DEFAULT
    xml = Harvestdor.public_xml(druid, purl_url)
    begin
      # preserve namespaces, etc for the node
      Nokogiri::XML(xml.root.xpath('/publicObject/dc:dc', {'dc' => Harvestdor::OAI_DC_NAMESPACE}).to_xml)
    rescue
      raise Harvestdor::Errors::MissingDC.new(druid)
    end
  end

  class Client
    
    # the public xml for this fedora object, from the purl server
    # @param [String] druid, e.g. ab123cd4567, in the purl url
    # @return [Nokogiri::XML::Document] the MODS metadata for the fedora object
    def mods druid
      Harvestdor.mods(druid, config.purl)
    end

    # the public xml for this fedora object, from the purl xml
    # @param [String] druid, e.g. ab123cd4567, in the purl url
    # @return [Nokogiri::XML::Document] the public xml for the fedora object
    def public_xml druid
      Harvestdor.public_xml(druid, config.purl)
    end

    # the contentMetadata for this fedora object, from the purl xml
    # @param [String] druid, e.g. ab123cd4567, in the purl url
    # @return [Nokogiri::XML::Document] the contentMetadata for the fedora object
    def content_metadata druid
      Harvestdor.content_metadata(druid, config.purl)
    end

    # the identityMetadata for this fedora object, from the purl xml
    # @param [String] druid, e.g. ab123cd4567, in the purl url
    # @return [Nokogiri::XML::Document] the identityMetadata for the fedora object
    def identity_metadata druid
      Harvestdor.identity_metadata(druid, config.purl)
    end

    # the rightsMetadata for this fedora object, from the purl xml
    # @param [String] druid, e.g. ab123cd4567, in the purl url
    # @return [Nokogiri::XML::Document] the rightsMetadata for the fedora object
    def rights_metadata druid
      Harvestdor.rights_metadata(druid, config.purl)
    end

    # the RDF for this fedora object, from the purl xml
    # @param [String] druid, e.g. ab123cd4567, in the purl url
    # @return [Nokogiri::XML::Document] the RDF for the fedora object
    def rdf druid
      Harvestdor.rdf(druid, config.purl)
    end

    # the Dublin Core for this fedora object, from the purl xml
    # @param [String] druid, e.g. ab123cd4567, in the purl url
    # @return [Nokogiri::XML::Document] the dc for the fedora object
    def dc druid
      Harvestdor.dc(druid, config.purl)
    end
    
  end # class Client

end # module Harvestdor