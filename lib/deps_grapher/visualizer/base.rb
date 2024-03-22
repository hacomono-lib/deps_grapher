# frozen_string_literal: true

require_relative "registry"
require_relative "command_option"
require_relative "color"

module DepsGrapher
  module Visualizer
    class Base
      class << self
        def command_option(name, default: false)
          Registry.register self, CommandOption.new(name, default)
        end
      end

      attr_reader :options

      def initialize(downloader, options)
        @downloader = downloader
        @options = options
        @nodes = []
        @edges = []
      end

      def accept!(nodes, edges)
        @nodes = nodes
        @edges = edges
        self
      end

      def render
        required_js.each do |url|
          @downloader.download url
        end

        ERB.new(File.read(template_path), trim_mode: "-").result(binding)
      end

      private

      def required_js
        []
      end

      def template_path
        raise NotImplementedError
      end

      def color(layer_name)
        Color[layer_name]
      end

      def color_map(type)
        Color.generate_map(type)
      end

      def arrow_color(layer_name)
        color(layer_name).arrow || background_color(layer_name)
      end

      def background_color(layer_name)
        color(layer_name).background
      end

      def font_color(layer_name)
        color(layer_name).font
      end

      def color_settings(layer_name)
        color(layer_name).settings
      end
    end
  end
end
