require 'nokogiri'
require 'net/http/persistent'

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
      Nokogiri::XML(http_client.get("#{purl_url}/#{druid}.mods").body,nil,'UTF-8')
    rescue Faraday::Error::ClientError
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
      ng_doc = Nokogiri::XML(http_client.get("#{purl_url}/#{druid}.xml").body)
      raise Harvestdor::Errors::MissingPublicXml.new(druid) if !ng_doc || ng_doc.children.empty?
      ng_doc
    rescue Faraday::Error::ClientError
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

  def self.http_client
    @http_client ||= Faraday.new do |conn|
      conn.adapter :net_http_persistent
      conn.use Faraday::Response::RaiseError
      conn.request :retry, max: 5,
                           interval: 0.05,
                           interval_randomness: 0.5,
                           backoff_factor: 2,
                           exceptions: ['Errno::ECONNRESET', 'Errno::ETIMEDOUT', 'Timeout::Error', 'Faraday::Error::TimeoutError', 'Faraday::Error::ConnectionFailed']
    end
  end
  private_class_method :http_client

end # module Harvestdor