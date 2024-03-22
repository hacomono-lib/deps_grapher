# frozen_string_literal: true

require_relative "visualizer/base"

module DepsGrapher
  class Vis < Visualizer::Base
    private

    def required_js
      ["https://unpkg.com/vis-network/standalone/umd/vis-network.min.js"]
    end

    def template_path
      File.expand_path File.join("vis", "template.erb"), __dir__
    end

    def shape
      raise NotImplementedError
    end

    def data
      nodes = @nodes.each_with_object([]) do |node, array|
        next if skip_node?(node)

        array << convert_node(node)
      end

      edges = @edges.each_with_object([]) do |edge, array|
        next if skip_edge?(edge)

        array << convert_edge(edge)
      end

      { nodes: nodes, edges: edges }
    end

    def convert_node(node)
      root_node = node.parent.nil?

      {
        id: node.id,
        label: node.label,
        shape: shape,
        size: (root_node ? 10 : 5) + [1.5 * node.deps_count, 20].min,
        font: {
          size: (root_node ? 8 : 5) + [1.2 * node.deps_count, 5].min,
          color: font_color(node.layer)
        },
        color: color_settings(node.layer).except(:font)
      }
    end

    def convert_edge(edge)
      {
        from: edge.from.id,
        to: edge.to.id,
        arrows: :to
      }
    end

    def skip_node?(node)
      options[:layers].present? && !options[:layers].include?(node.layer)
    end

    def skip_edge?(edge)
      skip_node?(edge.to)
    end
  end
end
