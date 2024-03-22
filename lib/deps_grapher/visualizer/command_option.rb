# frozen_string_literal: true

module DepsGrapher
  module Visualizer
    class CommandOption
      attr_reader :name

      def initialize(name, default)
        @name = name
        @default = default
      end

      def default?
        @default
      end

      def to_s
        name
      end
    end
  end
end
