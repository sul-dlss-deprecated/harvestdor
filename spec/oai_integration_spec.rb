require 'spec_helper'

describe 'Harvestdor::Client OAI Harvesting Integration Tests', :integration => true do

  before(:all) do
    @config_yml_path = File.join(File.dirname(__FILE__), "config", "oai.yml")
  end

  context "test OAI server" do
    before(:all) do
      @test_hclient ||= Harvestdor::Client.new({:config_yml_path => @config_yml_path, :oai_client_debug => 'true', :oai_repository_url => 'https://dor-oaiprovider-test.stanford.edu/oai'})
    end
    context "withOUT resumption tokens" do
      before(:all) do
        @opts = {:metadata_prefix => 'mods', :from => nil, :until => nil, :set => 'is_governed_by_hy787xj5878'}
      end
      it "should be able to harvest headers" do
        headers = @test_hclient.oai_headers(@opts)
        headers.should be_an_instance_of(Array)
        headers.size.should > 0
        headers.size.should < 50  # no resumption token
        headers.first.should be_an_instance_of(OAI::Header)
      end
      it "should be able to harvest records" do
        records = @test_hclient.oai_records(@opts)
        records.should be_an_instance_of(Array)
        records.size.should > 0
        records.size.should < 50  # no resumption token
        records.first.should be_an_instance_of(OAI::Record)
      end
    end
    context "with resumption tokens" do
      before(:all) do
        @opts = {:metadata_prefix => 'mods', :from => nil, :until => nil, :set => 'is_member_of_kh678dr8608'}
      end
      it "should be able to harvest headers" do
        pending "need to find small set > 50 on test"
        headers = @test_hclient.oai_headers(@opts)
        headers.should be_an_instance_of(Array)
        headers.size.should > 50
        headers.first.should be_an_instance_of(OAI::Header)
      end
      it "should be able to harvest records" do
        pending "need to find small set > 50 on test"
        records = @test_hclient.harvest_records(@opts)
        records.should be_an_instance_of(Array)
        records.size.should > 50
        records.first.should be_an_instance_of(OAI::Record)
      end
    end
  end
  
  context "production OAI server" do
    before(:all) do
      @prod_hclient ||= Harvestdor::Client.new({:config_yml_path => @config_yml_path, :oai_repository_url => 'https://dor-oaiprovider-prod.stanford.edu/oai'})
    end
    context "withOUT resumption tokens" do
      before(:all) do
        @opts = {:metadata_prefix => 'mods', :from => nil, :until => '2012-05-03T19:19:33Z', :set => 'is_governed_by_hy787xj5878'}
      end
      it "should be able to harvest headers" do
        headers = @prod_hclient.oai_headers(@opts)
        headers.should be_an_instance_of(Array)
        headers.size.should > 0
        headers.size.should < 50  # no resumption token
        headers.first.should be_an_instance_of(OAI::Header)
      end
      it "should be able to harvest records" do
        records = @prod_hclient.oai_records(@opts)
        records.should be_an_instance_of(Array)
        records.size.should > 0
        records.size.should < 50  # no resumption token
        records.first.should be_an_instance_of(OAI::Record)
      end
    end
    context "with resumption tokens" do
      before(:all) do
        @opts = {:metadata_prefix => 'mods', :from => nil, :until => nil, :set => 'is_member_of_collection_jh957jy1101'}
      end
      it "should be able to harvest headers" do
        headers = @prod_hclient.oai_headers(@opts)
        headers.should be_an_instance_of(Array)
        headers.size.should > 50
        headers.first.should be_an_instance_of(OAI::Header)
      end
      it "should be able to harvest records" do
        pending "the request always seems to time out"
        records = @prod_hclient.oai_records(@opts)
        records.should be_an_instance_of(Array)
        records.size.should > 50
        records.first.should be_an_instance_of(OAI::Record)
      end
    end
  end

end