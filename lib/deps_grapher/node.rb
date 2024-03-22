# frozen_string_literal: true

module DepsGrapher
  class Node
    class << self
      def guid
        @guid ||= 0
        @guid += 1
      end

      def fetch(class_name)
        registry[class_name]
      end

      def add(class_name, location)
        return nil if class_name.nil? || location.nil?

        registry[class_name] ||= new class_name, location
      end

      def all
        registry.values
      end

      private

      def registry
        @registry ||= {}
      end
    end

    private_class_method :new

    attr_accessor :id, :class_name, :location, :parent, :deps_count

    def initialize(class_name, location)
      @id = "n#{self.class.guid}"
      @class_name = class_name
      @location = location
      @parent = nil
      @deps_count = 0
    end

    def label
      deps_count.positive? ? "#{class_name} (#{deps_count})" : class_name
    end

    def layer
      @layer ||= Layer.fetch(location).name
    end

    def increment_deps_count!
      @deps_count += 1
    end

    def eql?(other)
      other.is_a?(self.class) && id == other.id
    end
    alias == eql?

    def hash
      id.hash
    end
  end
end
