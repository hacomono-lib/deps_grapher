# frozen_string_literal: true

# rubocop:disable Lint/EmptyBlock

RSpec.describe DepsGrapher::Layer do
  def create_block(name, file_name = File.join("*", "layer.rb"), &block)
    proc do
      name name
      source do
        root File.expand_path(File.join("..", "..", "..", "lib", "deps_grapher"), __dir__)
        include_pattern file_name
      end
      color do
        background "black"
        border "black"
        font "black"
      end
      instance_eval(&block) if block
    end
  end

  include_context "logging"

  describe ".fetch" do
    context "when the layer is registered" do
      it "returns the layer" do
        layer = described_class.new(&create_block(:layer1, File.join("*", "input.rb")))
        expect(described_class.fetch(File.expand_path(File.join("..", "..", "..", "lib", "deps_grapher", "input.rb"), __dir__))).to eq layer
      end
    end

    context "when the layer is not registered" do
      it "raises KeyError" do
        expect(described_class.fetch(:not_registered)).to eq described_class::Default
      end
    end
  end

  describe ".names" do
    it "returns the names of all layers" do
      described_class.new(&create_block(:layer1))
      described_class.new(&create_block(:layer2, File.join("*", "source_cache.rb")))
      expect(described_class.names).to contain_exactly(:layer1, :layer2)
    end

    context "when the files has been already registered" do
      it "returns the name of one layer" do
        described_class.new(&create_block(:layer1))
        described_class.new(&create_block(:layer2))
        expect(described_class.names).to contain_exactly(:layer1)
        expect(described_class.names).not_to contain_exactly(:layer2)
      end
    end
  end

  describe ".visible_names" do
    it "returns the names of all visible layers" do
      described_class.new(&create_block(:layer3) { visible true })
      described_class.new(&create_block(:layer4) { visible false })
      expect(described_class.visible_names).to contain_exactly(:layer3)
    end
  end

  describe ".exist?" do
    it "returns true if the layer exists" do
      described_class.new(&create_block(:layer5, File.join("*", "source.rb")))
      expect(described_class.exist?(File.expand_path(File.join("..", "..", "..", "lib", "deps_grapher", "source.rb"), __dir__))).to be true
    end

    it "returns false if the layer does not exist" do
      expect(described_class.exist?("NonexistentLayer")).to be false
    end
  end

  describe "#initialize" do
    context "when all required blocks are given" do
      it "registers the layer and creates a new source cache" do
        expect(DepsGrapher::Layer::Registry).to receive(:register)
        described_class.new(&create_block(:layer8))
      end
    end

    context "when no name is given" do
      it "raises an ArgumentError" do
        expect do
          described_class.new {}
        end.to raise_error(ArgumentError, "layer: no `name` given")
      end
    end

    context "when no source block is given" do
      it "raises an ArgumentError" do
        expect do
          described_class.new do
            name :layer9
            color do
              background "black"
              border "black"
              font "black"
            end
          end
        end.to raise_error(ArgumentError, "layer `layer9` has no `source` block")
      end
    end

    context "when no color block is given" do
      it "raises an ArgumentError" do
        expect do
          described_class.new do
            name :layer10
            source do
              root File.expand_path(File.join("..", "..", "..", "lib", "deps_grapher"), __dir__)
            end
          end
        end.to raise_error(ArgumentError, "layer `layer10` has no `color` block")
      end
    end
  end
end

# rubocop:enable Lint/EmptyBlock
