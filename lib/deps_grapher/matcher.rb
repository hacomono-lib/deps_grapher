# frozen_string_literal: true

module DepsGrapher
  class Matcher
    def initialize(pattern)
      @regexp = convert_to_regexp pattern
    end

    def match?(value)
      @regexp.match? value
    end

    def to_s
      @regexp.inspect
    end
    alias inspect to_s

    private

    def convert_to_regexp(pattern)
      if pattern.is_a?(Regexp)
        pattern
      else
        Regexp.new("\\A#{pattern.gsub(/\.?\*/, ".*")}\\z")
      end
    end
  end
end
