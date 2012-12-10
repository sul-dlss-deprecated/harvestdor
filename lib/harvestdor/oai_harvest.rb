require 'oai'

module Harvestdor

  # Mixin:  methods to perform an OAI harvest
  class Client

    # return Array of OAI::Records from the OAI harvest indicated by OAI params (metadata_prefix, from, until, set)
    # @return [Array<OAI::Record>] or enumeration over it, if block is given
    def harvest_records options = {}
      return to_enum(:harvest_records, options).to_a unless block_given?

      each_record(oai_options(options)) do |oai_rec|
        yield oai_rec
      end
    end
  
    # return Array of OAI::Headers from the OAI harvest indicated by OAI params (metadata_prefix, from, until, set)
    # @return [Array<OAI::Header>] or enumeration over it, if block is given
    def harvest_headers options = {}
      return to_enum(:harvest_headers, options).to_a unless block_given?
      
      each_header(oai_options(options)) do |oai_hdr|
        yield oai_hdr
      end
    end

    # return Array of druids contained in the OAI harvest indicated by OAI params (metadata_prefix, from, until, set)
    # @return [Array<String>] or enumeration over it, if block is given
    def harvest_ids options = {}
      return to_enum(:harvest_ids, options).to_a unless block_given?
      
      each_header(oai_options(options)) do |oai_hdr|
        yield Harvestdor.druid(oai_hdr)
      end
    end
    
    # @options [Hash] of OAI params (metadata_prefix, from, until, set) to be used in lieu of config.defaults
    # @return [Hash] of OAI params (metadata_prefix, from, until, set) set from options param or config.default values
    def oai_options options = {}
      oai_options={}
      oai_options[:metadata_prefix] = options.keys.include?(:metadata_prefix) ? options[:metadata_prefix] : config.default_metadata_prefix 
      oai_options[:from] = options.keys.include?(:from) ? options[:from] : config.default_from_date
      oai_options[:until] = options.keys.include?(:until) ? options[:until] : config.default_until_date
      oai_options[:set] = options.keys.include?(:set) ? options[:set] : config.default_set
      oai_options
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
      while response && response.entries.size > 0
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

  end # class OaiHarvester

end # module Harvestdor

