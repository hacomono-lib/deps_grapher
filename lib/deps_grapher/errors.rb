# frozen_string_literal: true

module DepsGrapher
  class Error < StandardError; end
  class TargetNodeNotFound < Error; end
  class SourceCacheNotFound < Error; end
  class SourceLocationNotFound < Error; end
end
