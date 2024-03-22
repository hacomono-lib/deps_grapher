# frozen_string_literal: true

module DepsGrapher
  class Source
    attr_accessor :root, :glob_pattern

    def initialize(name, &block)
      @name = name
      @include_pattern = nil
      @exclude_pattern = nil

      DSL.new(self).instance_eval(&block)

      assert!

      @glob_pattern = Array(glob_pattern.presence || File.join("**", "*.rb")).each_with_object([]) do |pattern, array|
        array << File.join(root, pattern)
      end
    end

    def files
      Dir.glob(glob_pattern).sort.uniq.each_with_object([]) do |file, files|
        next if include_pattern && !include_pattern.match?(file)
        next if exclude_pattern&.match?(file)

        files << file
      end
    end

    def include_pattern=(pattern)
      @include_pattern = Matcher.new pattern
    end

    def exclude_pattern=(pattern)
      @exclude_pattern = Matcher.new pattern
    end

    def to_s
      "glob_pattern: #{glob_pattern.inspect}, include_pattern: #{include_pattern.inspect}, exclude_pattern: #{exclude_pattern.inspect}"
    end

    private

    attr_reader :include_pattern, :exclude_pattern

    def assert!
      raise ArgumentError, "source: no `root` given" if root.blank?
      raise ArgumentError, "source: directory not found `#{root}`" unless Dir.exist?(root)
    end
  end
end
