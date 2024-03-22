# frozen_string_literal: true

RSpec.describe DepsGrapher::Graph do
  let(:graph) { described_class.new }

  before do
    allow(DepsGrapher::Layer).to receive(:extract_name!).and_return(:test)
  end

  let(:node1) { DepsGrapher::Node.add("TestNode1", "test_node1.rb") }
  let(:node2) { DepsGrapher::Node.add("TestNode2", "test_node2.rb") }
  let(:node3) { DepsGrapher::Node.add("TestNode3", "test_node3.rb") }
  let(:node4) { DepsGrapher::Node.add("TestNode4", "test_node4.rb") }
  let(:node5) { DepsGrapher::Node.add("TestNode5", "test_node5.rb") }
  let(:node6) { DepsGrapher::Node.add("TestNode6", "test_node6.rb") }

  describe "#add_edge" do
    it "adds edge to the graph" do
      graph.add_edge(DepsGrapher::Edge.add(node1, node2))
      expect(graph.instance_variable_get(:@graph)).to eq({ node1 => [node2] })

      graph.add_edge(DepsGrapher::Edge.add(node1, node3))
      expect(graph.instance_variable_get(:@graph)).to eq({ node1 => [node2, node3] })

      graph.add_edge(DepsGrapher::Edge.add(node2, node4))
      expect(graph.instance_variable_get(:@graph)).to eq({ node1 => [node2, node3], node2 => [node4] })

      graph.add_edge(DepsGrapher::Edge.add(node4, node5))
      expect(graph.instance_variable_get(:@graph)).to eq({ node1 => [node2, node3], node2 => [node4], node4 => [node5] })
    end
  end

  describe "#find_path" do
    let(:edge1) { DepsGrapher::Edge.add(node1, node2) }
    let(:edge2) { DepsGrapher::Edge.add(node1, node3) }
    let(:edge3) { DepsGrapher::Edge.add(node2, node4) }
    let(:edge4) { DepsGrapher::Edge.add(node3, node4) }
    let(:edge5) { DepsGrapher::Edge.add(node4, node5) }
    let(:edge6) { DepsGrapher::Edge.add(node1, node6) }

    before do
      graph.add_edge(edge1)
      graph.add_edge(edge2)
      graph.add_edge(edge3)
      graph.add_edge(edge4)
      graph.add_edge(edge5)
      graph.add_edge(edge6)
    end

    context "when source node is nil" do
      it "finds a path from any node to target node" do
        target_path_matcher = DepsGrapher::Matcher.new node5.class_name
        nodes, edges = graph.find_path(nil, target_path_matcher)
        expect(nodes).to match_array([node1, node2, node3, node4, node5])
        expect(edges).to match_array([edge1, edge2, edge3, edge4, edge5])
      end
    end

    context "when there is no path from source node to target node" do
      it "returns empty array" do
        source_path_matcher = DepsGrapher::Matcher.new node2.class_name
        target_path_matcher = DepsGrapher::Matcher.new node6.class_name
        nodes, edges = graph.find_path(source_path_matcher, target_path_matcher)
        expect(nodes).to eq(Set.new)
        expect(edges).to eq(Set.new)
      end
    end

    context "when there is a path from source node to target node" do
      it "finds a path from source node to target node" do
        source_path_matcher = DepsGrapher::Matcher.new node2.class_name
        target_path_matcher = DepsGrapher::Matcher.new node5.class_name
        nodes, edges = graph.find_path(source_path_matcher, target_path_matcher)
        expect(nodes).to match_array([node2, node4, node5])
        expect(edges).to match_array([edge3, edge5])
      end
    end
  end
end
