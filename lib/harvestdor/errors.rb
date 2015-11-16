module Harvestdor
  module Errors
    MissingPurlPage = Class.new(RuntimeError)
    MissingMods = Class.new(RuntimeError)
    MissingPublicXml = Class.new(RuntimeError)
    MissingContentMetadata = Class.new(RuntimeError)
    MissingIdentityMetadata = Class.new(RuntimeError)
    MissingRightsMetadata = Class.new(RuntimeError)
    MissingRDF = Class.new(RuntimeError)
    MissingDC = Class.new(RuntimeError)
  end
end