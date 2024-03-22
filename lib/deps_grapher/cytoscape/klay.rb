# frozen_string_literal: true

require_relative "../cytoscape"

module DepsGrapher
  class Cytoscape
    class Klay < self
      command_option "cy:klay", default: true

      private

      def required_js
        super.tap do |js|
          js << "https://unpkg.com/klayjs/klay.js"
          js << "https://raw.githubusercontent.com/cytoscape/cytoscape.js-klay/master/cytoscape-klay.js"
        end
      end

      def layout_options
        Visualizer::JsOption.new(
          name: :klay,
          nodeDimensionsIncludeLabels: true
        )
      end
    end
  end
end
