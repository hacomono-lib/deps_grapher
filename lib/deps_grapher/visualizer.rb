# frozen_string_literal: true

module DepsGrapher
  module Visualizer
    class << self
      def fetch(name)
        Registry.fetch name
      end
    end
  end
end
