# frozen_string_literal: true

module DepsGrapher
  class Event
    class << self
      def generate_key(name, const_name, method)
        return nil if const_name.nil? && method.nil?

        key = name.to_s.dup
        key << ".#{const_name}" if const_name
        key << ".#{method}" if method
        key
      end

      def add(name:, const_name:, location:, method: nil)
        key = generate_key name, const_name, method

        return nil if key.nil?

        registry[key] ||= new(
          name: name,
          const_name: const_name,
          location: location,
          method: method
        )
      end

      private

      def registry
        @registry ||= {}
      end
    end

    private_class_method :new

    attr_accessor :name, :const_name, :location, :method

    def initialize(name:, const_name:, location:, method:)
      @name = name
      @const_name = const_name
      @location = location
      @method = method
      @skip_processing = false
    end

    def key
      self.class.generate_key name, const_name, method
    end

    def processing!
      @skip_processing = false
    end

    def skip_processing!
      @skip_processing = true
    end

    def processing?
      !@skip_processing
    end
  end
end
