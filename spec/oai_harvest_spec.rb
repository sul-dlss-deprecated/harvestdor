require 'spec_helper'

describe 'Harvestdor::Client oai harvesting' do
  before(:all) do
    @harvestdor_client = Harvestdor::Client.new
  end
  
  describe "harvest_ids" do
    it "should use default values for OAI arguments if they are not present in the method param hash" do
      pending "to be implemented"
    end
    it "should use OAI arguments from the method param hash if they are present" do
      pending "to be implemented"
    end
    it "should return druids" do
      pending "to be implemented"
    end
    it "should have results viewable as an array" do
      pending "to be implemented"
    end
    it "should have enumerable results" do
      pending "to be implemented"
    end
    it "should yield to a passed block" do
      oai_response = mock('oai_response')
      oai_response.stub(:entries).and_return(['foo', 'bar'])
      oai_response.stub(:resumption_token).and_return('')
      @harvestdor_client.oai_client.stub(:list_identifiers).with(an_instance_of(Hash)) { 
          oai_response
      }
      expect { |b| @harvestdor_client.harvest_ids(&b) }.to yield_successive_args('foo', 'bar')
    end
  end
  
  describe "harvest_records" do    
    it "should use default values for OAI arguments if they are not present in the method param hash" do
      pending "to be implemented"
    end
    it "should use OAI arguments from the method param hash if they are present" do
      pending "to be implemented"
    end
    it "should return OAI::Record objects" do
      pending "to be implemented"
    end
    it "should have results viewable as an array" do
      pending "to be implemented"
    end
    it "should have enumerable results" do
      pending "to be implemented"
    end
    it "should yield to a passed block" do
      oai_response = mock('oai_response')
      oai_response.stub(:entries).and_return([1, 2])
      oai_response.stub(:resumption_token).and_return('')
      @harvestdor_client.oai_client.stub(:list_records).with(an_instance_of(Hash)) { 
          oai_response
      }
      expect { |b| @harvestdor_client.harvest_records(&b) }.to yield_successive_args(1, 2)
    end
  end  

  describe "each_oai_object" do
    it "should perform a list_records OAI request when first arg is true" do
      oai_response = mock('oai_response')
      oai_response.stub(:entries).and_return([])
      @harvestdor_client.oai_client.stub(:list_records).with(an_instance_of(Hash)) { 
          oai_response
      }
      @harvestdor_client.oai_client.should_receive(:list_records)
      @harvestdor_client.each_oai_object(true, {})
    end
    
    it "should perform a list_identifiers OAI request when first arg is false" do
      oai_response = mock('oai_response')
      oai_response.stub(:entries).and_return([])
      @harvestdor_client.oai_client.stub(:list_identifiers).with(an_instance_of(Hash)) { 
          oai_response
      }
      @harvestdor_client.oai_client.should_receive(:list_identifiers)
      @harvestdor_client.each_oai_object(false, {})
    end

    it "should use passed OAI arguments" do
      oai_response = mock('oai_response')
      oai_response.stub(:entries).and_return([])
      @harvestdor_client.oai_client.stub(:list_identifiers).with(an_instance_of(Hash)) { 
          oai_response
      }
      oai_options_hash = {:metadata_prefix => 'mods', :from => '2012-11-30'}
      @harvestdor_client.oai_client.should_receive(:list_identifiers).with(oai_options_hash)
      @harvestdor_client.each_oai_object(false, oai_options_hash)
    end
    
    it "should yield to a passed block" do
      oai_response = mock('oai_response')
      oai_response.stub(:entries).and_return([1, 2])
      oai_response.stub(:resumption_token).and_return('')
      @harvestdor_client.oai_client.stub(:list_records).with(an_instance_of(Hash)) { 
          oai_response
      }
      expect { |b| @harvestdor_client.each_oai_object(true, {}, &b) }.to yield_successive_args(1, 2)
    end

    context "resumption tokens" do
      it "should stop processing when no records/headers are received" do
        oai_response = mock('oai_response')
        oai_response.stub(:entries).and_return([])
        @harvestdor_client.oai_client.stub(:list_records).with(an_instance_of(Hash)) { 
            oai_response
        }

        i = 0
        @harvestdor_client.each_oai_object(true, {}) { |record| i += 1 }
        i.should == 0
      end

      it "should stop processing when the resumption token is empty" do
        oai_response_with_token = mock('oai_response')
        oai_response_with_token.stub(:entries).and_return([1,2,3,4,5])
        oai_response_with_token.stub(:resumption_token).and_return('')
        @harvestdor_client.oai_client.stub(:list_records).with(an_instance_of(Hash)) { 
          oai_response_with_token
        }

        i = 0
        @harvestdor_client.each_oai_object(true, {}) { |record| i += 1 }
        i.should == 5
      end

      it "should stop processing when there was no resumption token" do
        oai_response_with_token = mock('oai_response')
        oai_response_with_token.stub(:entries).and_return([1,2,3,4,5])
        oai_response_with_token.stub(:resumption_token).and_return(nil)
        @harvestdor_client.oai_client.stub(:list_records).with(an_instance_of(Hash)) { 
          oai_response_with_token
        }

        i = 0
        @harvestdor_client.each_oai_object(true, {}) { |record| i += 1 }
        i.should == 5
      end      
    end # resumption tokens
  end
  
  describe "collection_harvest?" do
    it "should do something" do
      pending "to be implemented"
    end
  end
  
  context "#is_a_collection?" do
    it "true if an OAI record is for a collection object" do
      pending
      @records[@batchelor_collection_druid.to_sym].solr_mapper.is_a_collection?.should eql(true)
    end
    it "true if an OAI header is for a collection object" do
      pending
    end
    it "false if an OAI record is not a collection object" do
      pending
      @records[:bc497ws1916].solr_mapper.is_a_collection?.should eql(false)
    end
    it "false if an OAI header is not a collection object" do
      pending
    end
  end

  describe "collection_object_druid" do
    it "should do something" do
      pending "to be implemented"
    end
  end
  
  it "should keep utf-8 encoded characters intact" do
    pending "to be implemented"
  end
    
end