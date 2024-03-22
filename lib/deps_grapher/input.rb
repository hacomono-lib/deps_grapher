# frozen_string_literal: true

module DepsGrapher
  class Input
    def initialize(config)
      @config = config
    end

    def files
      FileUtils.rm_rf File.dirname(config.cache_dir) if config.clean

      set_layers_visibility!
      extract_files_from_layers
    end

    private

    attr_reader :config

    def set_layers_visibility!
      layer_visibility = config.visualizer_options[:layers]

      config.layers.each_value do |layer|
        layer.visible = layer_visibility.include? layer.name
      end
    end

    def extract_files_from_layers
      config.layers.values.select(&:visible).each_with_object([]) do |layer, files|
        source = layer.source

        source.files.each do |file|
          next if file == config.path

          files << file
        end
      end
    end
  end
end
