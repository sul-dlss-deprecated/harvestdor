require "spec_helper"

describe Harvestdor do

  before(:all) do
    @dor_oai_provider_regex = /dor-oaiprovider.*oai$/
  end
  
  describe "client initialization" do
    before(:all) do
      @from_date = '2012-11-29'
      @repo_url = 'http://my_oai_repo.org/oai'
    end
    context "attributes passed in hash argument" do
      before(:all) do
        @some_args = Harvestdor::Client.new({:default_from_date => @from_date, :oai_repository_url => @repo_url}).config
      end
      it "should set the attributes to the passed values" do
        @some_args.oai_repository_url.should == @repo_url
        @some_args.default_from_date.should == @from_date
      end
      it "should keep the defaults for attributes not in the hash argument" do
        @some_args.log_name.should == Harvestdor::LOG_NAME_DEFAULT
        @some_args.log_dir.should == Harvestdor::LOG_DIR_DEFAULT
        @some_args.http_options.should == Confstruct::Configuration.new(Harvestdor::HTTP_OPTIONS_DEFAULT)
        @some_args.oai_client_debug.should == Harvestdor::OAI_CLIENT_DEBUG_DEFAULT
        @some_args.default_metadata_prefix.should == Harvestdor::DEFAULT_METADATA_PREFIX
        @some_args.default_until_date.should == Harvestdor::DEFAULT_UNTIL_DATE
        @some_args.default_set.should == Harvestdor::DEFAULT_SET
      end
    end
    
    context "config_yml_path in hash argument" do
      before(:all) do
        @config_yml_path = File.join(File.dirname(__FILE__), "config", "oai.yml")
        @config_via_yml_only = Harvestdor::Client.new({:config_yml_path => @config_yml_path}).config
        require 'yaml'
        @yaml = YAML.load_file(@config_yml_path)
      end
      it "should set attributes in yml file over defaults" do
        @config_via_yml_only.log_dir.should == @yaml['log_dir']
        @config_via_yml_only.oai_repository_url.should == @yaml['oai_repository_url']
        @config_via_yml_only.default_from_date.should == @yaml['default_from_date']
        @config_via_yml_only.default_metadata_prefix.should == @yaml['default_metadata_prefix']
        @config_via_yml_only.http_options.timeout.should == @yaml['http_options']['timeout']
      end
      it "should keep the defaults for attributes not present in yml file nor a config yml file" do
        @config_via_yml_only.log_name.should == Harvestdor::LOG_NAME_DEFAULT
        @config_via_yml_only.default_until_date.should == Harvestdor::DEFAULT_UNTIL_DATE
        @config_via_yml_only.default_set.should == Harvestdor::DEFAULT_SET
      end
      context "and some hash arguments" do
        before(:all) do
          @config_via_yml_plus = Harvestdor::Client.new({:config_yml_path => @config_yml_path, 
            :default_from_date => @from_date, :oai_repository_url => @repo_url}).config
        end
        it "should favor hash arg attribute values over yml file values" do
          @config_via_yml_plus.oai_repository_url.should == @repo_url
          @config_via_yml_plus.default_from_date.should == @from_date
        end
        it "should favor yml file values over defaults" do
          @config_via_yml_plus.log_dir.should == @yaml['log_dir']
          @config_via_yml_plus.default_metadata_prefix.should == @yaml['default_metadata_prefix']
          @config_via_yml_plus.http_options.timeout.should == @yaml['http_options']['timeout']
        end
        it "should keep the defaults for attributes not present in yml file" do
          @config_via_yml_plus.log_name.should == Harvestdor::LOG_NAME_DEFAULT
          @config_via_yml_plus.default_until_date.should == Harvestdor::DEFAULT_UNTIL_DATE
          @config_via_yml_plus.default_set.should == Harvestdor::DEFAULT_SET
        end
      end
    end
    
    context "without hash arguments" do
      it "should keep the defaults for all attributes" do
        c = Harvestdor::Client.new
        no_args = c.config
        no_args.log_name.should == Harvestdor::LOG_NAME_DEFAULT
        no_args.log_dir.should == Harvestdor::LOG_DIR_DEFAULT
        no_args.http_options.should == Confstruct::Configuration.new(Harvestdor::HTTP_OPTIONS_DEFAULT)
        no_args.oai_client_debug.should == Harvestdor::OAI_CLIENT_DEBUG_DEFAULT
        no_args.oai_repository_url.should == Harvestdor::OAI_REPOSITORY_URL_DEFAULT
        no_args.default_metadata_prefix.should == Harvestdor::DEFAULT_METADATA_PREFIX
        no_args.default_from_date.should == Harvestdor::DEFAULT_FROM_DATE
        no_args.default_until_date.should == Harvestdor::DEFAULT_UNTIL_DATE
        no_args.default_set.should == Harvestdor::DEFAULT_SET
      end
    end
  end # initialize client

  describe "config via attribute accessor on harvestdor client object" do
    it "should allow direct setting of log_dir" do
      pending "to be implemented"
    end
    it "should allow direct setting of log_name" do
      pending "to be implemented"
    end
    it "should allow direct setting of http client options" do
      pending "to be implemented"
    end
    it "should allow direct setting of oai_repository_url" do
      pending "to be implemented"
    end
    it "should allow direct setting of OAI client debug setting" do
      pending "to be implemented"
    end
    it "should allow direct setting of OAI rest arguments" do
      pending "to be implemented"
    end
  end

  describe "logging" do
    it "default log dir should be xxx" do
      pending "to be implemented"
    end
    
    
    it "should write the log file to the directory indicated by log_dir" do
      pending "to be implemented"
    end
    
    it "should have a logger" do
      Harvestdor.logger.should be_an_instance_of(Logger)
    end

  end
  
  context "oai client" do
    before(:all) do
      @default_client = Harvestdor::Client.new.oai_client
    end
    it "oai_client should return an OAI::Client object based on config data" do
p @default_client.identify.inspect      
      @default_client.should be_an_instance_of(OAI::Client)
    end
    
  end
  
  
  
end