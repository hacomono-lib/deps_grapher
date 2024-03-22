# frozen_string_literal: true

require_relative "cose"

module DepsGrapher
  class Cytoscape
    class Fcose < Cose
      command_option "cy:fcose"

      private

      def required_js
        super.tap do |js|
          js << "https://unpkg.com/cytoscape-fcose/cytoscape-fcose.js"
        end
      end

      def layout_options
        option = Visualizer::JsOption.new(
          name: :fcose,
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
