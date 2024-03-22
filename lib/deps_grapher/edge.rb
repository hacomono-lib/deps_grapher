# frozen_string_literal: true

module DepsGrapher
  class Edge
    class << self
      def fetch(from, to)
        id = generate_id from, to
        registry.fetch id
      end

      def add(from, to)
        return nil if from.nil? || to.nil?

        id = generate_id from, to

        return nil if registry.key?(id) || from.id == to.id

        to.parent = from.id
        to.increment_deps_count!

        registry[id] = new id, from, to
      end

      def all
        registry.values
      end

      private

      def generate_id(from, to)
        "e:#{from.id}:#{to.id}"
      end

      def registry
        @registry ||= {}
      end
    end

    private_class_method :new

    attr_accessor :id, :from, :to

    def initialize(id, from, to)
      @id = id
      @from = from
      @to = to
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
