# frozen_string_literal: true

require "parser/current"
require_relative "source_cache"
require_relative "node"
require_relative "edge"

module DepsGrapher
  class AstProcessor < Parser::AST::Processor
    include Logging

    class << self
      def processed
        @processed ||= Set.new
      end

      def event_processed
        @event_processed ||= Set.new
      end

      attr_writer :depth

      def depth
        @depth ||= 0
      end
    end

    def initialize(file_path, graph, event_processors, advanced_const_resolver, ignore_errors)
      super()
      @file_path = file_path
      @target = File.basename(file_path, ".*").camelize
      @graph = graph
      @event_processors = event_processors
      @advanced_const_resolver = advanced_const_resolver
      @ignore_errors = ignore_errors
    end

    def call
      return if self.class.processed.include?(@file_path)

      log do
        source_buffer = Parser::Source::Buffer.new(@file_path)
        parser = Parser::CurrentRuby.new
        process parser.parse(source_buffer.read)
      end
    end

    def on_module(ast_node)
      const_node = ast_node.children[0]
      name = extract_const_name const_node

      @namespace_stack ||= []
      @namespace_stack.push name

      if name == @target
        fully_qualified_class_name = @namespace_stack.join "::"
        @current_node = Node.add fully_qualified_class_name, @file_path
        self.class.processed << @file_path
      end

      super

      @namespace_stack.pop
    end
    alias on_class on_module

    def on_const(ast_node)
      const_name = extract_const_name ast_node

      process_recursively! const_name, ast_node do
        Event.add name: :const_found, const_name: _1, location: _2
      end

      super
    end

    def on_send(ast_node)
      if @current_node
        receiver_node, method_name, = *ast_node

        const_name = call_advanced_const_resolver ast_node
        const_name ||= extract_const_name receiver_node

        process_recursively! const_name, receiver_node do
          Event.add name: :method_found, const_name: _1, location: _2, method: method_name
        end
      end

      super
    end

    private

    def call_event_processor(event)
      return if event.blank? || @event_processors.blank?
      return if self.class.event_processed.include?(event.key)

      self.class.event_processed << event.key

      @event_processors.each do |matcher, (prop, event_processor)|
        if matcher.is_a?(Regexp)
          next unless matcher.match? event.send(prop)
        else
          next unless matcher == event.send(prop)
        end

        event_processor.call event
      end
    end

    def call_advanced_const_resolver(ast_node)
      return nil unless @advanced_const_resolver.respond_to?(:call)

      @advanced_const_resolver.call ast_node
    end

    def process_recursively!(const_name, ast_node)
      return unless @current_node

      begin
        const_name, location = if ast_node
                                 guess_source_location(const_name, ast_node)
                               else
                                 find_source_location!(const_name)
                               end
      rescue SourceLocationNotFound => e
        raise e unless @ignore_errors
      end

      return unless const_name && location

      event = yield const_name, location
      call_event_processor event

      return unless event&.processing?

      node = Node.add const_name, location
      edge = Edge.add @current_node, node

      return unless edge

      @graph.add_edge edge

      self.class.new(
        node.location,
        @graph,
        @event_processors,
        @advanced_const_resolver,
        @ignore_errors
      ).call
    end

    def extract_const_name(ast_node)
      return nil if ast_node.nil?

      return nil unless ast_node.type == :const

      base, name = *ast_node
      if base.nil?
        name.to_s
      else
        [extract_const_name(base), name].compact.join "::"
      end
    end

    def guess_namespace(file_path)
      const_name = SourceCache::Registry.fetch(file_path)
      namespace = const_name.split("::")
      parts = namespace.last
      while parts.present?
        return if yield(namespace)

        parts = namespace.pop
      end
    end

    def guess_source_location(const_name, ast_node)
      return if const_name.blank?

      find_source_location! const_name
    rescue SourceLocationNotFound
      guess_namespace(ast_node.location.name.source_buffer.name) do |ns|
        return find_source_location! [*ns, const_name].compact.join("::")
      rescue SourceLocationNotFound
        nil
      end
    end

    def find_source_location!(const_name)
      return if const_name.blank?

      location = SourceCache::Registry.fetch const_name
      [const_name, location]
    rescue SourceCacheNotFound
      raise SourceLocationNotFound, "source location not found for #{const_name}"
    end

    def log
      verbose do
        indent = "*" * self.class.depth
        indent << " " if indent.present?
        "Analyzing #{indent}#{@file_path}"
      end

      self.class.depth += 1
      yield
    ensure
      self.class.depth -= 1
    end
  end
end
