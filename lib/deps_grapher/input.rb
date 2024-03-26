# frozen_string_literal: true

module DepsGrapher
  class Input
    def initialize(config)
      @config = config
    end

    def files
      FileUtils.rm_rf File.dirname(config.cache_dir) if config.clean

      layer_visibilities = config.visualizer_options[:layers]

      files = []

      SourceCache::Registry.with_cache config.cache_key do |restored|
        config.layers.each_value do |layer|
          name = layer.name
          source = layer.source

          layer.visible = layer_visibilities.include? name

          SourceCache.register! name, source unless restored

          next unless layer.visible

          source.files.each do |file|
            next if file == config.path

            files << file
          end
        end
      end

      files
    end

    private

    attr_reader :config
  end
end
