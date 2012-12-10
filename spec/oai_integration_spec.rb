require 'spec_helper'

describe 'Harvestdor::Client OAI Harvesting Integration Tests' do

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
        @test_hclient.harvest_headers(@opts).should be_an_instance_of(Array)
      end
      it "should be able to harvest records" do
        @test_hclient.harvest_records(@opts).should be_an_instance_of(Array)
      end
    end
    context "with resumption tokens" do
      before(:all) do
        @opts = {:metadata_prefix => 'mods', :from => nil, :until => nil, :set => 'is_member_of_kh678dr8608'}
      end
      it "should be able to harvest headers" do
        @test_hclient.harvest_headers(@opts).should be_an_instance_of(Array)
      end
      it "should be able to harvest records" do
        @test_hclient.harvest_records(@opts).should be_an_instance_of(Array)
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
        @prod_hclient.harvest_headers(@opts).should be_an_instance_of(Array)
      end
      it "should be able to harvest records" do
        @prod_hclient.harvest_records(@opts).should be_an_instance_of(Array)
      end
    end
    context "with resumption tokens" do
      before(:all) do
        @opts = {:metadata_prefix => 'mods', :from => nil, :until => nil, :set => 'is_member_of_collection_jh957jy1101'}
      end
      it "should be able to harvest headers" do
        @prod_hclient.harvest_headers(@opts).should be_an_instance_of(Array)
      end
      it "should be able to harvest records" do
        @prod_hclient.harvest_records(@opts).should be_an_instance_of(Array)
      end
    end
  end

end