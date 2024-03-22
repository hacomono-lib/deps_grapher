# frozen_string_literal: true

module DepsGrapher
  class Configuration
    include PluginDSL

    class_attribute :path
    class_attribute :root_dir, default: File.expand_path(File.join("..", ".."), __dir__)
    class_attribute :visualizer
    class_attribute :visualizer_options, default: { layers: [] }
    class_attribute :source_path # source class name on graph
    class_attribute :target_path # target class name on graph
    class_attribute :clean, default: false
    class_attribute :logger
    class_attribute :cache_dir, default: File.expand_path(File.join("..", "..", "tmp", "deps_grapher", "cache"), __dir__)
    class_attribute :cache_ttl, default: 60 * 5 # 5 minutes
    class_attribute :output_dir, default: File.expand_path(File.join("..", "..", "tmp", "deps_grapher", "graph"), __dir__)
    class_attribute :ignore_errors, default: false
    class_attribute :verbose, default: false
    class_attribute :dump, default: false

    attr_accessor :layers

    def initialize
      self.logger = Logger.new($stderr).tap do
        _1.formatter = ->(_, _, _, msg) { "#{msg}\n" }
      end

      self.visualizer = Visualizer::Registry.default_visualizer

      @layers = {}
    end

    def available_visualizers
      Visualizer::Registry.available_visualizers
    end

    def load_plugin!
      PluginLoader.load! plugin_dir
    end

    def merge!(options)
      options.each do |key, value|
        send "#{key}=", value if respond_to?("#{key}=") && !value.nil?
      end
    end

    def input
      @input ||= Input.new(self)
    end

    def layer(&block)
      Layer.new(&block).tap do |layer|
        @layers[layer.name] = layer
      end
    end

    def ast_processor_policy(&block)
      AstProcessorPolicy.new context, &block
    end

    def plugin_dir(dir = nil)
      return @plugin_dir unless dir

      @plugin_dir = dir
    end

    def load!(file)
      return unless file

      file = File.expand_path file
      raise ArgumentError, "no such file: #{file}" unless File.exist?(file)

      self.path = file

      content = File.read file

      cache_key = Digest::MD5.hexdigest(content)

      SourceCache::Registry.with_cache cache_key do
        DSL.new(self).instance_eval content
      end

      return unless dump

      at_exit do
        warn ""
        warn "=============================="
        warn " Configuration"
        warn "=============================="
        puts content
      end
    end

    def context
      @context ||= Context.new self
    end
  end
end
