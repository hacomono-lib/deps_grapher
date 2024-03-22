# frozen_string_literal: true

module DepsGrapher
  class Layer
    module Registry
      class << self
        def fetch(file_path)
          registry[file_path] || Layer::Default
        end
        alias [] fetch

        def register(file_path, layer)
          registry[file_path] ||= layer
        end

        def exist?(file_path)
          registry.key? file_path
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
