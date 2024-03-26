# frozen_string_literal: true

module DepsGrapher
  class SourceCache
    include Logging

    class << self
      def register!(name, source)
        new(name, source).register!
      end
    end

    attr_reader :root

    def initialize(name, source)
      @name = name
      @source = source
      @root = @source.root
      @cache_by_const_name = {}
      @cache_by_location = {}
    end

    def register!
      class_name_extractor = ClassNameExtractor.new do |class_name, location|
        @cache_by_const_name[class_name] = location
        @cache_by_location[location] ||= class_name
      end

      verbose { "Collecting `#{@name}` layer by #{@source}" }

      start = Time.now

      @source.files.each do |file|
        class_name_extractor.extract! file
      end

      info do
        "Found #{@cache_by_const_name.size} modules/classes, #{@cache_by_location.size} locations in `#{@name}` layer (#{Time.now - start} sec)"
      end
      verbose { "" }

      Registry.register @cache_by_const_name, @cache_by_location

      ClassNameExtractor.cache.clear
    end
  end
end
