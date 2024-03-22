# frozen_string_literal: true

module DepsGrapher
  module Visualizer
    class Color
      module Registry
        class << self
          def fetch(layer_name)
            registry.fetch layer_name
          end
          alias [] fetch

          def register(layer_name, color)
            registry[layer_name] = color
          end

          def all
            registry.values
          end

          private

          def registry
            @registry ||= {}
          end
        end
      end
    end
  end
end
