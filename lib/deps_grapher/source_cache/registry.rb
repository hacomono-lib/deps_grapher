# frozen_string_literal: true

module DepsGrapher
  class SourceCache
    module Registry
      class << self
        def fetch(name)
          registry.fetch name
        rescue KeyError
          raise SourceCacheNotFound, "source cache not found: #{name}"
        end
        alias [] fetch

        def key?(name)
          registry.key? name
        end

        def register(by_const_name, by_location)
          by_const_name.each do |const_name, location|
            registry[const_name] ||= location
          end

          by_location.each do |location, const_name|
            registry[location] ||= const_name
          end
        end

        def with_cache(key)
          restore_cache! key
          yield
          persist_cache! key
        end

        def persist_cache!(key)
          cache_file = DepsGrapher.cache_file key
          cache_file.write @registry
        end

        def restore_cache!(key)
          cache_file = DepsGrapher.cache_file key
          loaded = cache_file.read

          unless loaded
            @restored_cache = false
            return
          end

          @registry = loaded
          @restored_cache = true
        end

        def restored_cache?
          @restored_cache
        end

        private

        def registry
          @registry ||= {}
        end
      end
    end
  end
end
