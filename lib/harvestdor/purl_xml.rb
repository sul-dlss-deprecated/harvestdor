# external gems
require 'nokogiri'

module Harvestdor
  
  # Mixin:  methods to retrieve Purl public xml pieces
  class Client
    
    # @param [String] the druid for the purl url
    def purl_url druid
      "#{config.purl}/#{druid}"
    end
    
    
    # the public xml for this fedora object, from the purl page
    # @param [String] the druid for the purl url
    # @return [Nokogiri::XML::Document] the public xml for the fedora object
    def public_xml druid
      begin
        Nokogiri::XML(open("#{purl_url(druid)}.xml"))
      rescue OpenURI::HTTPError
        raise Harvestdor::Errors::MissingPurlPage.new(druid)
      rescue
        raise Harvestdor::Errors::MissingPublicXml.new(druid)
      end
    end

    
    # the contentMetadata for this fedora object, from the purl xml
    # @param [String] the druid for the purl url
    # @return [Nokogiri::XML::Document] the contentMetadata for the fedora object
    def content_metadata druid
      begin
        xml = Nokogiri::XML(open("#{purl_url(druid)}.xml"))
        # preserve namespaces, etc for the node
        Nokogiri::XML(xml.root.xpath('/publicObject/contentMetadata').to_xml)
      rescue OpenURI::HTTPError
        raise Harvestdor::Errors::MissingPurlPage.new(druid)
      rescue
        raise Harvestdor::Errors::MissingContentMetadata.new(druid)
      end
    end

    # the identityMetadata for this fedora object, from the purl xml
    # @param [String] the druid for the purl url
    # @return [Nokogiri::XML::Document] the identityMetadata for the fedora object
    def identity_metadata druid
      begin
        xml = Nokogiri::XML(open("#{purl_url(druid)}.xml"))
        # preserve namespaces, etc for the node
        Nokogiri::XML(xml.root.xpath('/publicObject/identityMetadata').to_xml)
      rescue OpenURI::HTTPError
        raise Harvestdor::Errors::MissingPurlPage.new(druid)
      rescue
        raise Harvestdor::Errors::MissingIdentityMetadata.new(druid)
      end
    end

    # the rightsMetadata for this fedora object, from the purl xml
    # @param [String] the druid for the purl url
    # @return [Nokogiri::XML::Document] the rightsMetadata for the fedora object
    def rights_metadata druid
      begin
        xml = Nokogiri::XML(open("#{purl_url(druid)}.xml"))
        # preserve namespaces, etc for the node
        Nokogiri::XML(xml.root.xpath('/publicObject/rightsMetadata').to_xml)
      rescue OpenURI::HTTPError
        raise Harvestdor::Errors::MissingPurlPage.new(druid)
      rescue
        raise Harvestdor::Errors::MissingRightsMetadata.new(druid)
      end
    end

    # the RDF for this fedora object, from the purl xml
    # @param [String] the druid for the purl url
    # @return [Nokogiri::XML::Document] the RDF for the fedora object
    def rdf druid
      begin
        xml = Nokogiri::XML(open("#{purl_url(druid)}.xml"))
        # preserve namespaces, etc for the node
        Nokogiri::XML(xml.root.xpath('/publicObject/rdf:RDF', {'rdf' => Harvestdor::RDF_NAMESPACE}).to_xml)
      rescue OpenURI::HTTPError
        raise Harvestdor::Errors::MissingPurlPage.new(druid)
      rescue
        raise Harvestdor::Errors::MissingRDF.new(druid)
      end
    end

    # the Dublin Core for this fedora object, from the purl xml
    # @param [String] the druid for the purl url
    # @return [Nokogiri::XML::Document] the dc for the fedora object
    def dc druid
      begin
        xml = Nokogiri::XML(open("#{purl_url(druid)}.xml"))
        # preserve namespaces, etc for the node
        Nokogiri::XML(xml.root.xpath('/publicObject/dc:dc', {'dc' => Harvestdor::OAI_DC_NAMESPACE}).to_xml)
      rescue OpenURI::HTTPError
        raise Harvestdor::Errors::MissingPurlPage.new(druid)
      rescue
        raise Harvestdor::Errors::MissingDC.new(druid)
      end
    end

    def logger
      @logger ||= self.class.logger(config.log_dir, config.log_name)
    end

    protected #---------------------------------------------------------------------
    
    def oai_http_client
      logger.info "Constructing OAI http client with faraday options #{config.http_options.to_hash.inspect}"
      @oai_http_client ||= Faraday.new config.oai_repository_url, config.http_options.to_hash
    end

    # Global, memoized, lazy initialized instance of a logger
    # @param String directory for to get log file
    # @param String name of log file
    def self.logger(log_dir, log_name)
      Dir.mkdir(log_dir) unless File.directory?(log_dir) 
      @logger ||= Logger.new(File.join(log_dir, log_name), 'daily')
    end

  end # class Client
  
  # @param oai_header object or oai_identifier
  # @return [String] the druid part of an OAI identifier in an OAI header
  def self.druid(arg)
    oai_id = arg
    if arg.is_a?(OAI::Header)
      oai_id = arg.identifier
    elsif arg.is_a?(OAI::Record)
      oai_id = arg.header.identifier
    end
    oai_id.split('druid:').last
  end

end # module Harvestdor