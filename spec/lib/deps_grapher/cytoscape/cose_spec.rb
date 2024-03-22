# frozen_string_literal: true

RSpec.describe DepsGrapher::Cytoscape::Cose do
  let(:cy) { described_class.new(downloader, { layers: layers }) }
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

  include_context "logging"

  before do
    DepsGrapher::Layer.new do
      name :test
      source do
        root File.expand_path(File.join("..", "..", "..", "..", "lib", "deps_grapher"), __dir__)
        glob_pattern File.join("cytoscape", "cose.rb")
      end
      color do
        background "blue"
        border "black"
        font "white"
      end
    end
    allow(DepsGrapher::Layer).to receive(:extract_name!).and_return(:test)

    allow(downloader).to receive(:download).with("https://unpkg.com/cytoscape/dist/cytoscape.min.js")
    allow(downloader).to receive(:download).with("https://unpkg.com/layout-base/layout-base.js")
    allow(downloader).to receive(:download).with("https://unpkg.com/cose-base/cose-base.js")
  end

  it "command_option is `cy:cose`" do
    expect(DepsGrapher::Visualizer::Registry.send(:registry)["cy:cose"].first).to eq described_class
  end

  describe "#render" do
    before do
      cy.accept!(
        [node1, node2, node3, node4, node5, node6],
        [edge1, edge2, edge3, edge4, edge5, edge6]
      )
    end

    it "renders the graph" do
      html = cy.render
      expect(html).to include('<script src="cytoscape.min.js"></script>')
      expect(html).to include('<script src="layout-base.js"></script>')
      expect(html).to include('<script src="cose-base.js"></script>')
      expect(html).to include('"name":"cose"')
      expect(html).to include("selector: 'edge[layer=\"test\"]',")
      expect(html).to include("'line-color': 'blue',")
      expect(html).to include("'target-arrow-color': 'blue',")
    end
  end
end
