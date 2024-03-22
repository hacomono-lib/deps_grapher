# frozen_string_literal: true

RSpec.describe DepsGrapher::Vis::Dot do
  let(:vis) { described_class.new(downloader, { layers: layers }) }
  let(:downloader) { instance_double(DepsGrapher::Visualizer::Downloader) }
  let(:layers) { [] }

  let(:node1) { DepsGrapher::Node.add("TestNode1", "test_node1.rb") }
  let(:node2) { DepsGrapher::Node.add("TestNode2", "test_node2.rb") }
  let(:node3) { DepsGrapher::Node.add("TestNode3", "test_node3.rb") }
  let(:node4) { DepsGrapher::Node.add("TestNode4", "test_node4.rb") }
  let(:node5) { DepsGrapher::Node.add("TestNode5", "test_node5.rb") }
  let(:node6) { DepsGrapher::Node.add("TestNode6", "test_node6.rb") }

  let(:edge1) { DepsGrapher::Edge.add(node1, node2) }
  let(:edge2) { DepsGrapher::Edge.add(node1, node3) }
  let(:edge3) { DepsGrapher::Edge.add(node2, node4) }
  let(:edge4) { DepsGrapher::Edge.add(node3, node4) }
  let(:edge5) { DepsGrapher::Edge.add(node4, node5) }
  let(:edge6) { DepsGrapher::Edge.add(node1, node6) }

  before do
    DepsGrapher::Visualizer::Color.new(:test) do
      background "blue"
      border "black"
      font "white"
    end
    allow(downloader).to receive(:download).with("https://unpkg.com/vis-network/standalone/umd/vis-network.min.js")
  end

  it "command_option is `vis:dot`" do
    expect(DepsGrapher::Visualizer::Registry.send(:registry)["vis:dot"].first).to eq described_class
  end

  describe "#render" do
    before do
      vis.accept!(
        [node1, node2, node3, node4, node5, node6],
        [edge1, edge2, edge3, edge4, edge5, edge6]
      )
    end

    it "renders the graph" do
      html = vis.render
      expect(html).to include('<script src="vis-network.min.js"></script>')
      expect(html).to include('"shape":"dot"')
      expect(html).to match(/const json = {"nodes":\[.+?\],"edges":\[.+?\]};/)
      expect(html).to include("new vis.DataSet")
      expect(html).to include("new vis.Network")
    end
  end
end
