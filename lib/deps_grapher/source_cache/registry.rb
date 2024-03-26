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
          cache_file = DepsGrapher.cache_file key
          restore_cache! cache_file
          yield @cache_restoration
          persist_cache! cache_file
        end

        private

        def restore_cache!(cache_file)
          loaded = cache_file.read

          unless loaded
            @cache_restoration = false
            return
          end

          @registry = loaded
          @cache_restoration = true
        end

        def persist_cache!(cache_file)
          cache_file.write @registry
        end

        def registry
          @registry ||= {}
        end
      end
    end
  end
end
