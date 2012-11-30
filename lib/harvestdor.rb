require "harvestdor/version"
require "harvestdor/oai_harvest"
# external gems
require 'confstruct'
require 'oai'
# stdlib
require 'logger'
require 'yaml'

module Harvestdor
  
  LOG_NAME_DEFAULT = "harvestdor.log"
  LOG_DIR_DEFAULT = File.join(File.dirname(__FILE__), "..", "logs")
  HTTP_OPTIONS_DEFAULT = { 'ssl' => { 'verify' => false }, 
                           'timeout' => 500, 
                           'open_timeout' => 500 }
  OAI_CLIENT_DEBUG_DEFAULT = false
  OAI_REPOSITORY_URL_DEFAULT = 'https://dor-oaiprovider-prod.stanford.edu/oai'
  DEFAULT_METADATA_PREFIX = 'mods'
  DEFAULT_FROM_DATE = nil
  DEFAULT_UNTIL_DATE = nil
  DEFAULT_SET = nil

  class Client
    
    def self.default_config
      @class_config ||= Confstruct::Configuration.new({
        :log_dir => LOG_DIR_DEFAULT,
        :log_name => LOG_NAME_DEFAULT,
        :http_options => HTTP_OPTIONS_DEFAULT,
        :oai_repository_url => OAI_REPOSITORY_URL_DEFAULT,
        :oai_client_debug => OAI_CLIENT_DEBUG_DEFAULT,
        :default_metadata_prefix => DEFAULT_METADATA_PREFIX,
        :default_from_date => DEFAULT_FROM_DATE,
        :default_until_date => DEFAULT_UNTIL_DATE,
        :default_set => DEFAULT_SET
      })
    end
    
    def initialize options = {}
      config.configure(YAML.load_file(options[:config_yml_path])) if options[:config_yml_path]
      
      config.configure options
      
      yield(config) if block_given?
    end
    
    def config
      @config ||= Confstruct::Configuration.new(self.class.default_config)
    end
    
    # @return OAI::Client an instantiated OAI::Client object, based on config options
    def oai_client
      @oai_client ||= OAI::Client.new config.oai_repository_url, :debug => config.oai_client_debug, :http => config.oai_http_client
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