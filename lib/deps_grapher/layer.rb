# frozen_string_literal: true

require_relative "layer/registry"
require_relative "visualizer/color"

module DepsGrapher
  class Layer
    class << self
      def fetch(file_path)
        Registry.fetch file_path
      end

      def names
        Registry.all.to_set(&:name)
      end

      def visible_names
        Registry.all.select(&:visible).to_set(&:name)
      end

      def exist?(file_path)
        Registry.exist? file_path
      end
    end

    attr_accessor :name, :visible

    def initialize(&block)
      @visible = true
      DSL.new(self).instance_eval(&block)

      assert!

      return if default?

      source.files.each do |file|
        Registry.register file, self
      end

      SourceCache.register! name, source
    end

    def source(&block)
      @source_defined = true if block
      @source ||= Source.new(name, &block)
    end

    def color(&block)
      @color_defined = true if block
      Visualizer::Color.new(name, &block)
    end

    private

    def assert!
      raise ArgumentError, "layer: no `name` given" unless name
      raise ArgumentError, "layer `#{name}` has no `source` block" unless default? || @source_defined
      raise ArgumentError, "layer `#{name}` has no `color` block" unless @color_defined
    end

    def default?
      name == :__default
    end

    Default = (new do
      name :__default
      visible true
      color do
        background "#BDBDBD"
        border "#9E9E9E"
        font "#BDBDBD"
      end
    end).freeze
  end
end
