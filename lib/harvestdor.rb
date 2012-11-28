require "harvestdor/version"
# external gems
require 'confstruct'
require 'oai'
# stdlib
require 'logger'
require 'yaml'

module Harvestdor
  
  # @return OAI::Client an instantiated OAI::Client object, based on config options
  def self.oai_client
    @oai_client ||= OAI::Client.new self.oai_provider.repository_url, :debug => self.oai_provider.debug, :http => self.oai_http_client
  end
  
  def self.oai_provider
    self.config.oai_provider
  end

  def self.oai_http_client
    self.logger.info "Constructing OAI http client with faraday options #{self.oai_provider.http_options.to_hash.inspect}"
    @oai_http_client ||= Faraday.new self.oai_provider.repository_url, self.oai_provider.http_options.to_hash
  end

  def self.env_file
# FIXME: don't hardcode this!!!    
#    File.expand_path(File.dirname(__FILE__) + "/../config/environments/#{environment}.yaml")
    File.expand_path(File.dirname(__FILE__) + "/../config/dor.yml")
  end

  def self.environment
    ENV['ENVIRONMENT'] ||= 'test'
  end

  def self.config
    @config ||= Confstruct::Configuration.new YAML.load_file(self.env_file)[self.environment]
  end
  
  # Reload everything about Harvestdor, probably b/c you want to switch environments
  def self.reload_config
    @config = Confstruct::Configuration.new YAML.load_file(self.env_file)[self.environment]
    @oai_client = OAI::Client.new self.oai_provider.repository_url, :debug => self.oai_provider.debug, :http => self.oai_http_client
    @oai_http_client ||= Faraday.new self.oai_provider.repository_url, self.oai_http_options.to_hash
    @logger = Logger.new(File.join(@log_dir,"/#{self.environment}.log"),'daily')
  end
  
  def logger
    Logging.logger
  end
  
  # Global, memoized, lazy initialized instance of a logger
  def self.logger
    @log_dir = File.join(File.dirname(__FILE__), "..", "logs")    
    Dir.mkdir(@log_dir) unless File.directory?(@log_dir) 
    @logger ||= Logger.new(File.join(@log_dir,"/#{self.environment}.log"),'daily')
  end
  
end
