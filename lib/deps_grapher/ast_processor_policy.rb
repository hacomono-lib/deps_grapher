# frozen_string_literal: true

module DepsGrapher
  class AstProcessorPolicy
    def initialize(context, &block)
      @context = context
      DSL.new(self).instance_eval(&block)
    end

    def const(matcher, &block)
      event_processor matcher, :const_name, &block
    end

    def include_const(matcher)
      const matcher, &:processing!
    end

    def exclude_const(matcher)
      const matcher, &:skip_processing!
    end

    def location(matcher, &block)
      event_processor matcher, :location, &block
    end

    def include_location(matcher)
      location matcher, &:processing!
    end

    def exclude_location(matcher)
      location matcher, &:skip_processing!
    end

    def event_processor(matcher, prop, &block)
      @context.event_processors[matcher] = [prop, block]
    end

    def advanced_const_resolver(callable = nil, &block)
      raise ArgumentError, "You must provide a block or callable" unless block || callable
      raise ArgumentError, "The provided object must respond to #call" if callable && !callable.respond_to?(:call)

      @context.advanced_const_resolver = block || callable
    end
  end
end
