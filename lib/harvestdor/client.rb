module Harvestdor
  class Client
  
  # Set default values for the construction of Harvestdor::Client objects
  def self.default_config
    @class_config ||= Confstruct::Configuration.new({
      :log_dir => LOG_DIR_DEFAULT,
      :log_name => LOG_NAME_DEFAULT,
      :purl => PURL_DEFAULT,
      :http_options => HTTP_OPTIONS_DEFAULT
      })
    end
    
    # Initialize a new instance of Harvestdor::Client
    # @param Hash options
    # @example
    #   client = Harvestdor::Client.new({ # Example with all possible options
    #      :log_dir => File.join(File.dirname(__FILE__), "..", "logs"),
    #      :log_name => 'harvestdor.log',
    #      :purl => 'http://purl.stanford.edu',
    #      :http_options => { 'ssl' => { 
    #                          'verify' => false 
    #                          }, 
    #                         'request' => {
    #                            'timeout' => 30, # open/read timeout (seconds)
    #                            'open_timeout' => 30 # connection open timeout (seconds)
    #                          }
    #                        },
    #      :oai_repository_url => 'https://dor-oaiprovider-prod.stanford.edu/oai', # The OAI repository to connect to
    #      :oai_client_debug => false,
    #      :default_metadata_prefix => 'mods',
    #      :default_from_date => '2012-12-01', 
    #      :default_until_date => '2014-12-01',
    #      :default_set => nil, 
    #   })
    def initialize options = {}
      config.configure(YAML.load_file(options[:config_yml_path])) if options[:config_yml_path]
      config.configure options
      yield(config) if block_given?
    end
    
    def config
      @config ||= Confstruct::Configuration.new(self.class.default_config)
    end
    
    def logger
      @logger ||= self.class.logger(config.log_dir, config.log_name)
    end
    
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
    
    protected #---------------------------------------------------------------------
    
    # Global, memoized, lazy initialized instance of a logger
    # @param [String] log_dir directory for to get log file
    # @param [String] log_name name of log file
    def self.logger(log_dir, log_name)
      Dir.mkdir(log_dir) unless File.directory?(log_dir) 
      @logger ||= Logger.new(File.join(log_dir, log_name), 'daily')
    end
    
  end # class Client
end