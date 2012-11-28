require "spec_helper"

describe Harvestdor do

  before(:all) do
    @dor_oai_provider_regex = /dor-oaiprovider.*oai$/
  end

  it "should have a logger" do
    Harvestdor.logger.should be_an_instance_of(Logger)
  end
  
  it "env_file should find an environment file" do
    Harvestdor.stub(:environment).and_return('fake_environment')
    Harvestdor.env_file.should =~ /fake_environment/
#    def self.env_file
#      File.expand_path(File.dirname(__FILE__) + "/../config/environments/#{environment}.yaml")
#    end
  end

  it "environment should default to test" do
    stashed_env = ENV['ENVIRONMENT']
    ENV['ENVIRONMENT'] = nil
    Harvestdor.environment.should == 'test'
    ENV['ENVIRONMENT'] = stashed_env
  end
  
  describe "config" do
    before(:all) do
      @h = Harvestdor
      @conf = @h.config
    end
    it "should be a Confstruct::Configuration object" do
      @conf.should be_an_instance_of(Confstruct::Configuration)
    end
    it "should load the yaml file pointed to by .env_file" do
      pending "to be implemented"
    end
    it "should load the test environment by default" do
      pending "to be implemented"
    end
    it "should have a purl url" do
      @conf[:purl][:url].should =~ /http.*stanford/
    end
    describe "reload_config" do
      before(:all) do
        @first_config = @conf
        @first_oai_client = @h.oai_client
        @first_logger = @h.logger
        @h.reload_config
      end
      it "should create a new config object" do
        @h.config.object_id.should_not == @first_config.object_id
      end
      it "should create a new oai_client object" do
        @h.oai_client.should_not == @first_oai_client
      end
      it "should create a new logger" do
        @h.logger.should_not == @first_logger
      end
    end
  end
  
  it "oai_client should return an OAI::Client object" do
    Harvestdor.oai_client.should be_an_instance_of(OAI::Client)
  end
  
  describe "oai_http_client" do
    before(:all) do
      @http_client = Harvestdor.oai_http_client
    end
    it "should be a Faraday object" do
      @http_client.should be_an_instance_of(Faraday::Connection)
    end
    it "should have the oai_provider url" do
      uri_obj = @http_client.url_prefix
      (uri_obj.host + uri_obj.path).should =~ @dor_oai_provider_regex
    end
  end
  
  describe "oai_provider" do
    before(:all) do
      @oai_p = Harvestdor.oai_provider
    end
    it "should be a Confstruct::HashWithStructAccess" do
      @oai_p.class.should == Confstruct::HashWithStructAccess
    end
    it "should have a dor oaiprovider repository url" do
      @oai_p[:repository_url].should =~ @dor_oai_provider_regex
    end
    it "should have a default metadata prefix of mods" do
      @oai_p[:default_metadata_prefix].should == 'mods'
    end
  end
  
end