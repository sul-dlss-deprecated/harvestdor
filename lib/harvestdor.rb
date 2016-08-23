require 'harvestdor/errors'
require 'harvestdor/purl_xml'
require 'harvestdor/version'
require 'harvestdor/client'
# external gems
require 'confstruct'
# stdlib
require 'logger'
require 'faraday'
require 'yaml'

module Harvestdor

  LOG_NAME_DEFAULT = "harvestdor.log"
  LOG_DIR_DEFAULT = File.join(File.dirname(__FILE__), "..", "logs")
  PURL_DEFAULT = 'https://purl.stanford.edu'
end # module Harvestdor