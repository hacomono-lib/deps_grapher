# frozen_string_literal: true

module DepsGrapher
  class NullGraph
    def add_edge(_); end
  end

  class Graph
    def initialize
      @graph = {}
    end

    def add_edge(edge)
      @graph[edge.from] ||= []
      @graph[edge.from] << edge.to
    end

    def find_path(source_path_matcher, target_path_matcher)
      paths = []
      visited = {}

      @graph.each_key do |start_node|
        next if source_path_matcher && !source_path_matcher.match?(start_node.class_name)

        dfs start_node, target_path_matcher, visited, [start_node], paths
      end

      nodes = Set.new
      edges = Set.new

      paths.each do |path|
        collect! path, nodes, edges
      end

      [nodes, edges]
    end

    private

    def dfs(current, target_path_matcher, visited, path, paths)
      visited[current] = true

      if target_path_matcher.match?(current.class_name)
        paths << path
      else
        @graph[current]&.each do |node|
          next if visited[node]

          dfs node, target_path_matcher, visited, path + [node], paths
        end
      end

      visited[current] = false
    end

    def collect!(path, nodes, edges)
      current_node = nil
      path.each do |node|
        nodes << node

        if current_node.nil?
          current_node = node
          next
        end

        edges << Edge.fetch(current_node, node)
        current_node = node
      end
    end
  end
end
