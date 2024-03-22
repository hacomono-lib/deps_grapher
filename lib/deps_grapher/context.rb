# frozen_string_literal: true

require "forwardable"

module DepsGrapher
  class Context
    extend Forwardable

    def_delegators :@config,
                   :ignore_errors,
                   :source_path,
                   :target_path

    attr_accessor :event_processors, :advanced_const_resolver

    def initialize(config)
      @config = config
      @event_processors = {}
    end

    def clean_dir!
      return unless @config.clean

      FileUtils.rm_rf @config.output_dir
    end

    def generate_graphile(dest)
      Graphile::Generator.new(@config).call dest
    end

    def generate_temp_graphile
      generate_graphile nil
    end

    def create_writer
      HtmlWriter.new @config.output_dir
    end

    def create_visualizer
      downloader = Visualizer::Downloader.new @config.output_dir
      Visualizer.fetch(@config.visualizer).new downloader, @config.visualizer_options
    end

    def create_graph
      target_path ? Graph.new : NullGraph.new
    end
  end
end
