require 'oai'

module Harvestdor

  # Mixin:  methods to perform an OAI harvest
  class Client

=begin
    def find_by_sparql query, options = { :binding => 'pid' }
      return to_enum(:find_by_sparql, query, options).to_a unless block_given?

      self.sparql(query).each do |x|
        obj = self.find(x[options[:binding]]) rescue nil
        yield obj if obj
      end
    end
=end
  
    # NAOMI_MUST_COMMENT_THIS_METHOD
    # @return [Array<OAI::Record>] or enumeration over it, if block is given
    def harvest_records options = {}
      return to_enum(:harvest_records, options).to_a unless block_given?
      
      oai_options={}
      oai_options[:metadata_prefix] = options[:metadata_prefix] ? options[:metadata_prefix] : config.default_metadata_prefix 
      oai_options[:from] = options[:from] ? options[:from] : config.default_from_date
      oai_options[:until] = options[:until] ? options[:until] : config.default_until_date
      oai_options[:set] = options[:set] ? options[:set] : config.default_set

      each_record(oai_options) do |oai_rec|
        yield oai_rec
      end
    end
  
    # NAOMI_MUST_COMMENT_THIS_METHOD
    # @return [Array<OAI::Header>] or enumeration over it, if block is given
    def harvest_ids options = {}
      return to_enum(:harvest_ids, options).to_a unless block_given?
      
      oai_options={}
      oai_options[:metadata_prefix] = options[:metadata_prefix] ? options[:metadata_prefix] : config.default_metadata_prefix 
      oai_options[:from] = options[:from] ? options[:from] : config.default_from_date
      oai_options[:until] = options[:until] ? options[:until] : config.default_until_date
      oai_options[:set] = options[:set] ? options[:set] : config.default_set

      each_header(oai_options) do |oai_hdr|
        yield Harvestdor.druid(oai_hdr)
      end
    end
    
    # Iterate over the OAI client's records (following resumption tokens) and yield OAI::Record
    # @return enumeration of [OAI::Record]
    def each_record (oai_args, &block)
      each_oai_object(true, oai_args, &block)
    end
    
    # Iterate over the OAI client's headers (following resumption tokens) and yield OAI::Header
    # @return enumeration of [OAI::Header]
    def each_header (oai_args, &block)
      each_oai_object(false, oai_args, &block)
    end
    
    # Iterate over the OAI client's records (following resumption tokens) and yield OAI::Record
    # @param [Boolean] harvest_records set to true to harvest OAI::Record objects; false for OAI::Header objects
    # @return enumeration of [OAI::Record]
    # TODO: This could be moved into ruby-oai?
    def each_oai_object (harvest_records, oai_args, &block)
      list_method_sym = :list_identifiers
      if harvest_records
        list_method_sym = :list_records
      end
      
      response = oai_client.send list_method_sym, oai_args
      while response.entries.size > 0
        response.entries.each &block

        token = response.resumption_token
        if token.nil? or token.empty?
          break
        else
          response = oai_client.send(list_method_sym, :resumption_token => token)
        end
      end
    rescue Faraday::Error::TimeoutError => e
      Harvestdor.logger.error "No response from OAI Provider"
      Harvestdor.logger.error e
    rescue OAI::Exception => e
      # possibly unnecessary after ruby-oai 0.0.14
      Harvestdor.logger.error "Received unexpected OAI::Exception"
      Harvestdor.logger.error e
    end
    
    
    
    # Are we harvesting a set that contains a collection object? 
    def collection_harvest?
      oai_options && oai_options[:set] && oai_options[:set].match(/is_member_of_collection/)
    end
  
    # If the set we're harvesting includes a collection object, return the druid of the collection object.
    # Otherwise, return nil. 
    def collection_object_druid
      if collection_harvest?
        oai_options[:set].split('_').last
      else
        nil
      end
    end  
  
  end # class OaiHarvester

end # module Harvestdor

