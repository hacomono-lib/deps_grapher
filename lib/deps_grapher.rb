# frozen_string_literal: true

require "optparse"
require "active_support"
require "active_support/core_ext"
require "json"
require "fileutils"
require "prism"
require "net/https"
require "logger"
require "erb"
require "tempfile"
require "digest/md5"
require_relative "deps_grapher/version"
require_relative "deps_grapher/errors"
require_relative "deps_grapher/logging"
require_relative "deps_grapher/dsl"
require_relative "deps_grapher/plugin_dsl"

module DepsGrapher
  class << self
    def config
      @config ||= Configuration.new
    end

    def configure
      yield config
    end

    def logger
      config.logger
    end

    def cache_file(key)
      CacheFile.new(file: File.join(config.cache_dir, key.to_s), ttl: config.cache_ttl).tap do |cache_file|
        cache_file.clean! force: config.clean
      end
    end
  end
end

Dir.glob(File.expand_path(File.join("**", "*.rb"), __dir__)).sort.each { |f| require f }
