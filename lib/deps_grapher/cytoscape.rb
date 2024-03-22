# frozen_string_literal: true

require_relative "visualizer/base"

module DepsGrapher
  class Cytoscape < Visualizer::Base
    def required_js
      [
        "https://unpkg.com/cytoscape/dist/cytoscape.min.js",
        "https://unpkg.com/layout-base/layout-base.js"
      ]
    end

    private

    def template_path
      File.expand_path File.join("cytoscape", "template.erb"), __dir__
    end

    def min_width
      "10"
    end

    def min_height
      "10"
    end

    def coefficient
      "0.2 * 10"
    end

    def layout_options
      raise NotImplementedError
    end

    def advanced_render
      ""
    end

    def data
      [].tap do |array|
        @nodes.each do |node|
          next if skip_node?(node)

          array << convert_node(node)
        end

        @edges.each do |edge|
          next if skip_edge?(edge)

          array << convert_edge(edge)
        end
      end
    end

    def convert_node(node)
      {
        group: :nodes,
        data: {
          id: node.id,
          layer: node.layer,
          label: node.label,
          deps_count: node.deps_count
        }
      }
    end

    def convert_edge(edge)
      {
        group: :edges,
        data: {
          id: edge.id,
          source: edge.from.id,
          target: edge.to.id,
          layer: edge.from.layer
        }
      }
    end

    def skip_node?(node)
      options[:layers].present? && !options[:layers].include?(node.layer)
    end

    def skip_edge?(edge)
      skip_node?(edge.from) || skip_node?(edge.to)
    end
  end
end
