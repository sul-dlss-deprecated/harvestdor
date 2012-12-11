require 'spec_helper'

describe 'Harvestdor::Client oai harvesting' do
  before(:all) do
    @harvestdor_client = Harvestdor::Client.new
    @oai_arg_defaults = {:metadata_prefix => @harvestdor_client.config.default_metadata_prefix, 
                :from => @harvestdor_client.config.default_from_date,
                :until => @harvestdor_client.config.default_until_date,
                :set => @harvestdor_client.config.default_set  }
  end
  
  describe "harvest_ids" do
    before(:each) do
      oai_response = mock('oai_response')
      oai_response.stub(:entries).and_return(['foo', 'bar'])
      oai_response.stub(:resumption_token).and_return('')
      @harvestdor_client.oai_client.stub(:list_identifiers).with(an_instance_of(Hash)) { 
          oai_response
      }
    end
    it "should return druids" do
      header1 = OAI::Header.new(nil)
      header1.identifier = 'oai:searchworks.stanford.edu/druid:foo'
      header2 = OAI::Header.new(nil)
      header2.identifier = 'oai:searchworks.stanford.edu/druid:bar'
      oai_response = mock('oai_response')
      oai_response.stub(:entries).and_return([header1, header2])
      @harvestdor_client.harvest_ids.should == ['foo', 'bar']
    end
    it "should have results viewable as an array" do
      @harvestdor_client.harvest_ids.should be_an_instance_of(Array)
    end
    it "should have enumerable results" do
      @harvestdor_client.harvest_ids.should respond_to(:each, :count)
    end
    it "should yield to a passed block" do
      expect { |b| @harvestdor_client.harvest_ids(&b) }.to yield_successive_args('foo', 'bar')
    end
  end
  
  describe "harvest_records" do
    before(:each) do
      @oai_response = mock('oai_response')
      @oai_response.stub(:entries).and_return([1, 2])
      @oai_response.stub(:resumption_token).and_return('')
      @harvestdor_client.oai_client.stub(:list_records).with(an_instance_of(Hash)) { 
          @oai_response
      }
    end
    it "should return OAI::Record objects" do
      header1 = OAI::Header.new(nil)
      header1.identifier = 'oai:searchworks.stanford.edu/druid:foo'
      oai_rec1 = OAI::Record.new(nil)
      oai_rec1.header = header1
      header2 = OAI::Header.new(nil)
      header2.identifier = 'oai:searchworks.stanford.edu/druid:bar'
      oai_rec2 = OAI::Record.new(nil)
      oai_rec2.header = header2
      @oai_response.stub(:entries).and_return([oai_rec1, oai_rec2])
      @harvestdor_client.harvest_records.should == [oai_rec1, oai_rec2]
    end
    it "should have results viewable as an array" do
      @harvestdor_client.harvest_records.should be_an_instance_of(Array)
    end
    it "should have enumerable results" do
      @harvestdor_client.harvest_records.should respond_to(:each, :count)
    end
    it "should yield to a passed block" do
      expect { |b| @harvestdor_client.harvest_records(&b) }.to yield_successive_args(1, 2)
    end
  end  

  describe "harvest_headers" do
    before(:each) do
      @oai_response = mock('oai_response')
      @oai_response.stub(:entries).and_return([1, 2])
      @oai_response.stub(:resumption_token).and_return('')
      @harvestdor_client.oai_client.stub(:list_identifiers).with(an_instance_of(Hash)) { 
          @oai_response
      }
    end
    it "should return OAI::Record objects" do
      header1 = OAI::Header.new(nil)
      header1.identifier = 'oai:searchworks.stanford.edu/druid:foo'
      header2 = OAI::Header.new(nil)
      header2.identifier = 'oai:searchworks.stanford.edu/druid:bar'
      @oai_response.stub(:entries).and_return([header1, header2])
      @harvestdor_client.harvest_headers.should == [header1, header2]
    end
    it "should have results viewable as an array" do
      @harvestdor_client.harvest_headers.should be_an_instance_of(Array)
    end
    it "should have enumerable results" do
      @harvestdor_client.harvest_headers.should respond_to(:each, :count)
    end
    it "should yield to a passed block" do
      expect { |b| @harvestdor_client.harvest_headers(&b) }.to yield_successive_args(1, 2)
    end
  end  
  
  describe "oai_options" do
    before(:all) do
      @expected_oai_args = @oai_arg_defaults.dup
      @expected_oai_args.each { |k, v|  
        @expected_oai_args.delete(k) if v.nil? || v.size == 0
      }
      
    end
    it "should use client's default values for OAI arguments if they are not present in the method param hash" do
      @harvestdor_client.oai_options.should == @expected_oai_args
    end
    it "should use OAI arguments from the method param hash if they are present" do
      passed_options = {:metadata_prefix => 'mods', :from => '2012-11-30'}
      @harvestdor_client.oai_options(passed_options).should == @expected_oai_args.merge(passed_options)
    end
    it "should use nil value for option when it is passed in options hash" do
      client = Harvestdor::Client.new({:default_from_date => '2012-01-01'})
      client.config.default_from_date.should == '2012-01-01'
      passed_options = {:from => nil}
      client.oai_options(passed_options)[:from].should == nil
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
      @harvestdor_client.each_oai_object(:list_records, {})
    end
    
    it "should perform a list_identifiers OAI request when first arg is false" do
      oai_response = mock('oai_response')
      oai_response.stub(:entries).and_return([])
      @harvestdor_client.oai_client.stub(:list_identifiers).with(an_instance_of(Hash)) { 
          oai_response
      }
      @harvestdor_client.oai_client.should_receive(:list_identifiers)
      @harvestdor_client.each_oai_object(:list_identifiers, {})
    end

    it "should use passed OAI arguments" do
      oai_response = mock('oai_response')
      oai_response.stub(:entries).and_return([])
      @harvestdor_client.oai_client.stub(:list_identifiers).with(an_instance_of(Hash)) { 
          oai_response
      }
      oai_options_hash = {:metadata_prefix => 'mods', :from => '2012-11-30'}
      @harvestdor_client.oai_client.should_receive(:list_identifiers).with(oai_options_hash)
      @harvestdor_client.each_oai_object(:list_identifiers, oai_options_hash)
    end
    
    it "should yield to a passed block" do
      oai_response = mock('oai_response')
      oai_response.stub(:entries).and_return([1, 2])
      oai_response.stub(:resumption_token).and_return('')
      @harvestdor_client.oai_client.stub(:list_records).with(an_instance_of(Hash)) { 
          oai_response
      }
      expect { |b| @harvestdor_client.each_oai_object(:list_records, {}, &b) }.to yield_successive_args(1, 2)
    end

    context "resumption tokens" do
      it "should stop processing when no records/headers are received" do
        oai_response = mock('oai_response')
        oai_response.stub(:entries).and_return([])
        @harvestdor_client.oai_client.stub(:list_records).with(an_instance_of(Hash)) { 
            oai_response
        }

        i = 0
        @harvestdor_client.each_oai_object(:list_records, {}) { |record| i += 1 }
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
        @harvestdor_client.each_oai_object(:list_records, {}) { |record| i += 1 }
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
        @harvestdor_client.each_oai_object(:list_records, {}) { |record| i += 1 }
        i.should == 5
      end      
    end # resumption tokens
  end
    
  it "should keep utf-8 encoded characters intact" do
    pending "to be implemented"
  end
    
end