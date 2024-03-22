# frozen_string_literal: true

module DepsGrapher
  class CacheFile
    include Logging

    def initialize(file:, ttl:)
      @file = file
      @ttl = ttl
    end

    def write(target)
      return if File.exist?(@file)

      FileUtils.mkdir_p File.dirname(@file)

      info { "Writing cache to #{@file}" }

      File.open(@file, "w") do |f|
        Marshal.dump target, f
      end
    end

    def read
      return nil unless File.exist?(@file)

      info { "Reading cache from #{@file} (#{File.size(@file)} bytes)" }

      File.open(@file) do |f|
        return Marshal.load f
      end
    end

    def stale?
      return false unless File.exist?(@file)

      File.mtime(@file).to_i < (Time.now.to_i - @ttl)
    end

    def clean!(force: false)
      return unless File.exist?(@file)
      return unless force || stale?

      FileUtils.rm_f @file
      info { "Removed stale cache file: #{@file}" }
    end
  end
end
