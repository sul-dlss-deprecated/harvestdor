require "spec_helper"

describe Harvestdor::Client do

  before(:all) do
    @config_yml_path = File.join(File.dirname(__FILE__), "config", "oai.yml")
    @client_via_yml_only = Harvestdor::Client.new({:config_yml_path => @config_yml_path})
    require 'yaml'
    @yaml = YAML.load_file(@config_yml_path)
  end

  describe "initialization" do
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
        @some_args.purl.should == Harvestdor::PURL_DEFAULT
        @some_args.http_options.should == Confstruct::Configuration.new(Harvestdor::HTTP_OPTIONS_DEFAULT)
        @some_args.oai_client_debug.should == Harvestdor::OAI_CLIENT_DEBUG_DEFAULT
        @some_args.default_metadata_prefix.should == Harvestdor::DEFAULT_METADATA_PREFIX
        @some_args.default_until_date.should == Harvestdor::DEFAULT_UNTIL_DATE
        @some_args.default_set.should == Harvestdor::DEFAULT_SET
      end
    end
    
    context "config_yml_path in hash argument" do
      before(:all) do
        @config_via_yml_only = @client_via_yml_only.config
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
        @config_via_yml_only.purl.should == Harvestdor::PURL_DEFAULT
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
        no_args = Harvestdor::Client.new.config
        no_args.log_name.should == Harvestdor::LOG_NAME_DEFAULT
        no_args.log_dir.should == Harvestdor::LOG_DIR_DEFAULT
        no_args.purl.should == Harvestdor::PURL_DEFAULT
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
  
  it "should allow direct setting of configuration attributes" do
    conf = Harvestdor::Client.new.config
    conf.log_dir.should == Harvestdor::LOG_DIR_DEFAULT
    conf['log_dir'] = 'my_log_dir'
    conf.log_dir.should == 'my_log_dir'
  end

  describe "logging" do
    it "should write the log file to the directory indicated by log_dir" do
      @client_via_yml_only.logger.info("harvestdor_client_spec logging test message")
      File.exists?(File.join(@yaml['log_dir'], Harvestdor::LOG_NAME_DEFAULT)).should == true
    end
  end
  
  context "oai_client" do
    before(:all) do
      @client = Harvestdor::Client.new
      @default_oai_client = Harvestdor::Client.new.oai_client
    end
    
    it "oai_client should return an OAI::Client object based on config data" do
      @default_oai_client.should be_an_instance_of(OAI::Client)
    end 

    context "oai_http_client (protected method)" do
	    before(:all) do
	      @http_client = @client.send(:oai_http_client)
	    end
	    it "should be a Faraday object" do
	      @http_client.should be_an_instance_of(Faraday::Connection)
	    end
	    it "should have the oai_provider url from config" do
	      uri_obj = @http_client.url_prefix
	      @client.config.oai_repository_url.should =~ Regexp.new(uri_obj.host + uri_obj.path)
	    end
	  end
  end # context oai_client
  
end