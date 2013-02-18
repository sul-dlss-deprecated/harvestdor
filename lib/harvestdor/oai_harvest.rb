require 'oai'

module Harvestdor

  # Mixin:  methods to perform an OAI harvest and iterate over results
  class Client

    # return Array of OAI::Records from the OAI harvest indicated by OAI params (metadata_prefix, from, until, set)
    # @param [Hash] oai_args optional OAI params (:metadata_prefix, :from, :until, :set) to be used in lieu of config default values
    # @return [Array<OAI::Record>] or enumeration over it, if block is given
    def oai_records oai_args = {}
      return to_enum(:oai_records, oai_args).to_a unless block_given?

      harvest(:list_records, scrub_oai_args(oai_args)) do |oai_rec|
        yield oai_rec
      end 
    end
  
    # return Array of OAI::Headers from the OAI harvest indicated by OAI params (metadata_prefix, from, until, set)
    # @param [Hash] oai_args optional OAI params (:metadata_prefix, :from, :until, :set) to be used in lieu of config default values
    # @return [Array<OAI::Header>] or enumeration over it, if block is given
    def oai_headers oai_args = {}
      return to_enum(:oai_headers, oai_args).to_a unless block_given?
      
      harvest(:list_identifiers, scrub_oai_args(oai_args)) do |oai_hdr|
        yield oai_hdr
      end
    end

    # return Array of druids contained in the OAI harvest indicated by OAI params (metadata_prefix, from, until, set)
    # @param [Hash] oai_args optional OAI params (:metadata_prefix, :from, :until, :set) to be used in lieu of config default values
    # @return [Array<String>] or enumeration over it, if block is given
    def druids_via_oai oai_args = {}
      return to_enum(:druids_via_oai, oai_args).to_a unless block_given?

      harvest(:list_identifiers, scrub_oai_args(oai_args)) do |oai_hdr|
        yield Harvestdor.druid(oai_hdr)
      end
    end
    
    # get a single OAI record using a get_record OAI request
    # @param [String] druid (which will be turned into OAI identifier)
    # @param [String] md_prefix the OAI metadata prefix determining which metadata will be in the retrieved OAI::Record object
    # @return [OAI::Record] record object retrieved from OAI server
    def oai_record druid, md_prefix = 'mods'
      prefix = md_prefix ? md_prefix : config.default_metadata_prefix
      oai_client.get_record({:identifier => "oai:searchworks.stanford.edu/druid:#{druid}", :metadata_prefix => prefix}).record
    end
    
    protected #---------------------------------------------------------------------

    # @param [Hash] oai_args Hash of OAI params (metadata_prefix, from, until, set) to be used in lieu of config default values
    # @return [Hash] OAI params (metadata_prefix, from, until, set) cleaned up for making harvest request
    def scrub_oai_args oai_args = {}
      scrubbed_args={}
      scrubbed_args[:metadata_prefix] = oai_args.keys.include?(:metadata_prefix) ? oai_args[:metadata_prefix] : config.default_metadata_prefix 
      scrubbed_args[:from] = oai_args.keys.include?(:from) ? oai_args[:from] : config.default_from_date
      scrubbed_args[:until] = oai_args.keys.include?(:until) ? oai_args[:until] : config.default_until_date
      scrubbed_args[:set] = oai_args.keys.include?(:set) ? oai_args[:set] : config.default_set
      scrubbed_args.each { |k, v|  
        scrubbed_args.delete(k) if v.nil? || v.size == 0
      }
      scrubbed_args
    end
    
    # harvest OAI headers or OAI records and return a response object with one entry for each record/header retrieved
    #  follows resumption tokens (i.e. chunks are all present in result)
    # @param [Symbol] verb :list_identifiers or :list_records
    # @param [Hash] oai_args OAI params (metadata_prefix, from, until, set) used for request
    # @return response to OAI request, as one enumerable object 
    # TODO: This could be moved into ruby-oai?
    def harvest (verb, oai_args, &block)
      response = oai_client.send verb, oai_args
      while response && response.entries.size > 0
        response.entries.each &block

        token = response.resumption_token
        if token.nil? or token.empty?
          break
        else
          response = oai_client.send(verb, :resumption_token => token)
        end
      end
    rescue Faraday::Error::TimeoutError => e
      logger.error "No response from OAI Provider"
      logger.error e
      raise e
    rescue OAI::Exception => e
      # possibly unnecessary after ruby-oai 0.0.14
      logger.error "Received unexpected OAI::Exception"
      logger.error e
      raise e
    end

  end # class OaiHarvester

end # module Harvestdor

module OAI
  class Client
    # monkey patch to adjust timeouts
    # Do the actual HTTP get, following any temporary redirects
    def get(uri)
      # OLD: response = @http_client.get uri
      response = @http_client.get do |req|
        req.url uri
        req.options[:timeout] = 500           # open/read timeout in seconds
        req.options[:open_timeout] = 500      # connection open timeout in seconds
      end
      response.body
    end
  end
end