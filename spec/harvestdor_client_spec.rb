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
      @some_args = Harvestdor::Client.new.config
    end
      
    context "attributes passed in hash argument" do
      it "should keep the defaults for attributes not in the hash argument" do
        expect(@some_args.log_name).to eql(Harvestdor::LOG_NAME_DEFAULT)
        expect(@some_args.log_dir).to eql(Harvestdor::LOG_DIR_DEFAULT)
        expect(@some_args.purl).to eql(Harvestdor::PURL_DEFAULT)
        expect(@some_args.http_options).to eql(Confstruct::Configuration.new(Harvestdor::HTTP_OPTIONS_DEFAULT))
      end
    end
    
    context "config_yml_path in hash argument" do
      before(:all) do
        @config_via_yml_only = @client_via_yml_only.config
      end
      it "should set attributes in yml file over defaults" do
        expect(@config_via_yml_only.log_dir).to eql(@yaml['log_dir'])
        expect(@config_via_yml_only.http_options.request.timeout).to eql(@yaml['http_options']['request']['timeout'])
      end
      it "should keep the defaults for attributes not present in yml file nor a config yml file" do
        expect(@config_via_yml_only.log_name).to eql(Harvestdor::LOG_NAME_DEFAULT)
        expect(@config_via_yml_only.purl).to eql(Harvestdor::PURL_DEFAULT)
      end
      context "and some hash arguments" do
        before(:all) do
          @config_via_yml_plus = Harvestdor::Client.new({:config_yml_path => @config_yml_path}).config
        end
        it "should favor yml file values over defaults" do
          expect(@config_via_yml_plus.log_dir).to eql(@yaml['log_dir'])
          expect(@config_via_yml_plus.http_options.timeout).to eql(@yaml['http_options']['timeout'])
        end
        it "should keep the defaults for attributes not present in yml file" do
          expect(@config_via_yml_plus.log_name).to eql(Harvestdor::LOG_NAME_DEFAULT)
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
  
end