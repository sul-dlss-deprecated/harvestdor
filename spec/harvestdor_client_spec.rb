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
        expect(@some_args.oai_repository_url).to eql(@repo_url)
        expect(@some_args.default_from_date).to eql(@from_date)
      end
      it "should keep the defaults for attributes not in the hash argument" do
        expect(@some_args.log_name).to eql(Harvestdor::LOG_NAME_DEFAULT)
        expect(@some_args.log_dir).to eql(Harvestdor::LOG_DIR_DEFAULT)
        expect(@some_args.purl).to eql(Harvestdor::PURL_DEFAULT)
        expect(@some_args.http_options).to eql(Confstruct::Configuration.new(Harvestdor::HTTP_OPTIONS_DEFAULT))
        expect(@some_args.oai_client_debug).to eql(Harvestdor::OAI_CLIENT_DEBUG_DEFAULT)
        expect(@some_args.default_metadata_prefix).to eql(Harvestdor::DEFAULT_METADATA_PREFIX)
        expect(@some_args.default_until_date).to eql(Harvestdor::DEFAULT_UNTIL_DATE)
        expect(@some_args.default_set).to eql(Harvestdor::DEFAULT_SET)
      end
    end
    
    context "config_yml_path in hash argument" do
      before(:all) do
        @config_via_yml_only = @client_via_yml_only.config
      end
      it "should set attributes in yml file over defaults" do
        expect(@config_via_yml_only.log_dir).to eql(@yaml['log_dir'])
        expect(@config_via_yml_only.oai_repository_url).to eql(@yaml['oai_repository_url'])
        expect(@config_via_yml_only.default_from_date).to eql(@yaml['default_from_date'])
        expect(@config_via_yml_only.default_metadata_prefix).to eql(@yaml['default_metadata_prefix'])
        expect(@config_via_yml_only.http_options.request.timeout).to eql(@yaml['http_options']['request']['timeout'])
      end
      it "should keep the defaults for attributes not present in yml file nor a config yml file" do
        expect(@config_via_yml_only.log_name).to eql(Harvestdor::LOG_NAME_DEFAULT)
        expect(@config_via_yml_only.purl).to eql(Harvestdor::PURL_DEFAULT)
        expect(@config_via_yml_only.default_until_date).to eql(Harvestdor::DEFAULT_UNTIL_DATE)
        expect(@config_via_yml_only.default_set).to eql(Harvestdor::DEFAULT_SET)
      end
      context "and some hash arguments" do
        before(:all) do
          @config_via_yml_plus = Harvestdor::Client.new({:config_yml_path => @config_yml_path, 
            :default_from_date => @from_date, :oai_repository_url => @repo_url}).config
        end
        it "should favor hash arg attribute values over yml file values" do
          expect(@config_via_yml_plus.oai_repository_url).to eql(@repo_url)
          expect(@config_via_yml_plus.default_from_date).to eql(@from_date)
        end
        it "should favor yml file values over defaults" do
          expect(@config_via_yml_plus.log_dir).to eql(@yaml['log_dir'])
          expect(@config_via_yml_plus.default_metadata_prefix).to eql(@yaml['default_metadata_prefix'])
          expect(@config_via_yml_plus.http_options.timeout).to eql(@yaml['http_options']['timeout'])
        end
        it "should keep the defaults for attributes not present in yml file" do
          expect(@config_via_yml_plus.log_name).to eql(Harvestdor::LOG_NAME_DEFAULT)
          expect(@config_via_yml_plus.default_until_date).to eql(Harvestdor::DEFAULT_UNTIL_DATE)
          expect(@config_via_yml_plus.default_set).to eql(Harvestdor::DEFAULT_SET)
        end
      end
    end
    
    context "without hash arguments" do
      it "should keep the defaults for all attributes" do
        no_args = Harvestdor::Client.new.config
        expect(no_args.log_name).to eql(Harvestdor::LOG_NAME_DEFAULT)
        expect(no_args.log_dir).to eql(Harvestdor::LOG_DIR_DEFAULT)
        expect(no_args.purl).to eql(Harvestdor::PURL_DEFAULT)
        expect(no_args.http_options).to eql(Confstruct::Configuration.new(Harvestdor::HTTP_OPTIONS_DEFAULT))
        expect(no_args.oai_client_debug).to eql(Harvestdor::OAI_CLIENT_DEBUG_DEFAULT)
        expect(no_args.oai_repository_url).to eql(Harvestdor::OAI_REPOSITORY_URL_DEFAULT)
        expect(no_args.default_metadata_prefix).to eql(Harvestdor::DEFAULT_METADATA_PREFIX)
        expect(no_args.default_from_date).to eql(Harvestdor::DEFAULT_FROM_DATE)
        expect(no_args.default_until_date).to eql(Harvestdor::DEFAULT_UNTIL_DATE)
        expect(no_args.default_set).to eql(Harvestdor::DEFAULT_SET)
      end
    end
  end # initialize client
  
  it "should allow direct setting of configuration attributes" do
    conf = Harvestdor::Client.new.config
    expect(conf.log_dir).to eql(Harvestdor::LOG_DIR_DEFAULT)
    conf['log_dir'] = 'my_log_dir'
    expect(conf.log_dir).to eql('my_log_dir')
  end

  describe "logging" do
    it "should write the log file to the directory indicated by log_dir" do
      @client_via_yml_only.logger.info("harvestdor_client_spec logging test message")
      expect(File.exists?(File.join(@yaml['log_dir'], Harvestdor::LOG_NAME_DEFAULT))).to eql(true)
    end
  end
  
  context "oai_client" do
    before(:all) do
      @client = Harvestdor::Client.new
      @default_oai_client = Harvestdor::Client.new.oai_client
    end
    
    it "oai_client should return an OAI::Client object based on config data" do
      expect(@default_oai_client).to be_an_instance_of(OAI::Client)
    end 
    
    it "oai_client should have an http_client" do
      expect(@default_oai_client.instance_variable_get(:@http_client)).to be_an_instance_of(Faraday::Connection)
    end

    context "oai_http_client (protected method)" do
	    before(:all) do
	      @http_client = @client.send(:oai_http_client)
	    end
	    it "should be a Faraday object" do
	      expect(@http_client).to be_an_instance_of(Faraday::Connection)
	    end
	    it "should have the oai_provider url from config" do
	      uri_obj = @http_client.url_prefix
	      expect(@client.config.oai_repository_url).to match(Regexp.new(uri_obj.host + uri_obj.path))
	    end
	  end
  end # context oai_client
  
end