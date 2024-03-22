# frozen_string_literal: true

RSpec.describe DepsGrapher::Visualizer::Registry do
  describe ".fetch" do
    context "when the key exists in the registry" do
      it "fetches the value from the registry" do
        expect(described_class.fetch("cy:klay")).to eq DepsGrapher::Cytoscape::Klay
      end
    end

    context "when the key does not exist in the registry" do
      let(:key) { "non_existing_key" }

      it "raises a KeyError" do
        expect { described_class.fetch(key) }.to raise_error(KeyError)
      end
    end
  end

  describe ".default_visualizer" do
    it "returns the default visualizer" do
      expect(described_class.default_visualizer).to eq "cy:klay"
    end
  end

  describe ".available_visualizers" do
    it "returns the available visualizers" do
      expect(described_class.available_visualizers).to eq ["cy:cose", "cy:fcose", "cy:klay", "vis:box", "vis:dot"]
    end
  end

  describe ".register" do
    context "when the key is not a subclass of DepsGrapher::Visualizer::Base" do
      it "raises an ArgumentError" do
        expect do
          command_option = instance_double(DepsGrapher::Visualizer::CommandOption, name: "key")
          described_class.register(String, command_option)
        end.to raise_error ArgumentError, "visualizer: `String` must be a subclass of `DepsGrapher::Visualizer::Base`"
      end
    end

    context "when the key is a subclass of DepsGrapher::Visualizer::Base" do
      it "registers the key and visualizer in the registry" do
        key = "custom"

        custom_visualizer = Class.new(DepsGrapher::Visualizer::Base)
        command_option = instance_double(DepsGrapher::Visualizer::CommandOption, name: key)
        described_class.register(custom_visualizer, command_option)
        expect(described_class.fetch(key)).to eq custom_visualizer
        described_class.class_eval { registry.delete(key) }
      end
    end
  end
end
