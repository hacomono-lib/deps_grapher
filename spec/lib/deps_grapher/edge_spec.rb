# frozen_string_literal: true

RSpec.describe DepsGrapher::Edge do
  let(:from_node) { DepsGrapher::Node.add "TestClass1", "location1" }
  let(:to_node) { DepsGrapher::Node.add "TestClass2", "location2" }

  before do
    allow(DepsGrapher::Layer).to receive(:extract_name!).and_return(:test)
  end

  describe ".fetch" do
    context "when the edge exists" do
      let!(:edge) { described_class.add(from_node, to_node) }

      it "returns the edge" do
        expect(described_class.fetch(from_node, to_node)).to eq(edge)
        expect(to_node.parent).to eq(from_node.id)
        expect(to_node.deps_count).to eq(1)
      end
    end

    context "when the edge does not exist" do
      it "raises KeyError" do
        expect { described_class.fetch(from_node, to_node) }.to raise_error(KeyError)
      end
    end
  end

  describe ".add" do
    context "when the from_node and to_node are not nil" do
      it "adds a new edge to the registry" do
        expect { described_class.add(from_node, to_node) }.to change { described_class.all.count }.by(1)
      end
    end

    context "when the from_node or to_node is nil" do
      it "does not add a new edge to the registry" do
        expect { described_class.add(nil, to_node) }.not_to(change { described_class.all.count })
        expect { described_class.add(from_node, nil) }.not_to(change { described_class.all.count })
      end
    end
  end

  describe "#eql?" do
    let(:edge) { described_class.add(from_node, to_node) }

    it "returns true if the ids are equal" do
      expect(edge.eql?(described_class.fetch(from_node, to_node))).to be true
    end

    it "returns false if the ids are not equal" do
      other_node = DepsGrapher::Node.add "TestClass3", "location3"
      expect(edge.eql?(described_class.add(from_node, other_node))).to be false
    end

    context "when the other object is not an instance of Edge" do
      it "returns false" do
        expect(edge.eql?(edge.id)).to be false
      end
    end
  end

  describe "#id" do
    let(:edge) { described_class.add(from_node, to_node) }

    it "returns the id of the edge" do
      expect(edge.id).to eq("e:#{from_node.id}:#{to_node.id}")
    end
  end

  describe "#hash" do
    let(:edge) { described_class.add(from_node, to_node) }

    it "returns the hash of the id" do
      expect(edge.hash).to eq(edge.id.hash)
    end
  end
end
