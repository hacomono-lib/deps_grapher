# frozen_string_literal: true

module DepsGrapher
  module Visualizer
    module Registry
      class << self
        def fetch(key)
          registry.fetch(key).first
        end

        def default_visualizer
          command_options.find(&:default?).to_s
        end

        def available_visualizers
          command_options.map(&:to_s)
        end

        def register(klass, command_option)
          raise ArgumentError, "visualizer: `#{klass}` must be a subclass of `DepsGrapher::Visualizer::Base`" unless klass.ancestors.include?(Visualizer::Base)

          registry[command_option.name] = [klass, command_option]
        end

        private

        def command_options
          registry.values.map { _2 }
        end

        def registry
          @registry ||= {}
        end
      end
    end
  end
end
