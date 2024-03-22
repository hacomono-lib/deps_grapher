# frozen_string_literal: true

require_relative "../cytoscape"

module DepsGrapher
  class Cytoscape
    class Cose < self
      command_option "cy:cose"

      private

      def required_js
        super.tap do |js|
          js << "https://unpkg.com/cose-base/cose-base.js"
        end
      end

      def layout_options
        option = Visualizer::JsOption.new(
          name: :cose,
          directed: true,
          padding: 10,
          nodeOverlap: 20,
          refresh: 20,
          numIter: 1000,
          initialTemp: 200,
          coolingFactor: 0.95,
          minTemp: 1.0
        )
        option.add_function(name: :nodeRepulsion, args: :edge, body: "return 100000")
        option.add_function(name: :idealEdgeLength, args: :edge, body: "return 100")
        option.add_function(name: :edgeElasticity, args: :edge, body: "return 32")
      end
    end
  end
end
