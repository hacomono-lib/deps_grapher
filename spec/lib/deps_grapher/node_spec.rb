# frozen_string_literal: true

RSpec.describe DepsGrapher::Node do
  before do
    layer = instance_double(DepsGrapher::Layer, name: :test)
    allow(DepsGrapher::Layer).to receive(:fetch).and_return(layer)
  end

  describe ".fetch" do
    context "when the node exists" do
      let!(:node) { described_class.add("TestClass", "location") }

      it "returns the node" do
        expect(described_class.fetch("TestClass")).to eq(node)
      end
    end

    context "when the node does not exist" do
      it "returns nil" do
        expect(described_class.fetch("NonexistentClass")).to be_nil
      end
    end
  end

  describe ".add" do
    context "when the class name and location are not nil" do
      it "adds a new node to the registry" do
        expect { described_class.add("TestClass", "location") }.to change { described_class.all.count }.by(1)
      end
    end

    context "when the class name or location is nil" do
      it "does not add a new node to the registry" do
        expect { described_class.add(nil, "location") }.not_to(change { described_class.all.count })
        expect { described_class.add("TestClass", nil) }.not_to(change { described_class.all.count })
      end
    end
  end

  describe ".all" do
    let!(:node1) { described_class.add("TestClass", "location") }
    let!(:node2) { described_class.add("TestClass2", "location2") }

    it "returns all nodes in the registry" do
      expect(described_class.all).to match_array([node1, node2])
    end
  end

  describe "#increment_deps_count!" do
    let(:node) { described_class.add("TestClass", "location") }

    it "increments the deps_count of the node" do
      expect { node.increment_deps_count! }.to change { node.deps_count }.by(1)
    end
  end

  describe "#id" do
    let(:node) { described_class.add("TestClass", "location") }

    it "returns the id of the node" do
      10.times do |i|
        node = described_class.add("TestClass#{i}", "location#{i}")
        expect(node.id).to eq("n#{i + 1}")
      end
    end
  end

  describe "#layer" do
    let!(:node) { described_class.add("TestClass", "location") }

    it "returns the layer of the node" do
      expect(node.layer).to eq(:test)
    end
  end

  describe "#label" do
    let!(:node) { described_class.add("TestClass", "location") }

    context "when the node has deps_count > 0" do
      it "returns the class name with the deps_count" do
        node.increment_deps_count!
        expect(node.label).to eq("TestClass (1)")
      end
    end

    context "when the node has deps_count = 0" do
      it "returns the class name" do
        expect(node.label).to eq("TestClass")
      end
    end
  end

  describe "#eql?" do
    let(:node) { described_class.add("TestClass", "location") }

    it "returns true if the ids are equal" do
      expect(node.eql?(described_class.fetch("TestClass"))).to be true
    end

    it "returns false if the ids are not equal" do
      other_node = described_class.add("TestClass2", "location2")
      expect(node.eql?(other_node)).to be false
    end

    context "when the other object is not an instance of Node" do
      it "returns false" do
        expect(node.eql?(node.id)).to be false
      end
    end
  end

  describe "#hash" do
    let!(:node) { described_class.add("TestClass", "location") }

    it "returns the hash of the id" do
      expect(node.hash).to eq(node.id.hash)
    end
  end
end
