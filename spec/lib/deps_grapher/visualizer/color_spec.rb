# frozen_string_literal: true

RSpec.describe DepsGrapher::Visualizer::Color do
  let(:layer_name) { :test_layer }

  def create_block(background: "#000", border: "#111", font: "#ccc")
    proc do
      background background
      border border
      font font
    end
  end

  describe ".fetch" do
    context "when the color is registered" do
      it "returns the color" do
        color = described_class.new(layer_name, &create_block)

        expect(described_class.fetch(layer_name)).to eq color
      end
    end

    context "when the color is not registered" do
      it "raises KeyError" do
        expect { described_class[:not_registered] }.to raise_error KeyError
      end
    end
  end

  describe ".generate_map" do
    it "returns a hash of layer names and their colors" do
      described_class.new(:test1, &create_block(background: "#000", border: "#111", font: "#ccc"))
      described_class.new(:test2, &create_block(background: "#222", border: "#333", font: "#444"))
      described_class.new(:test3, &create_block(background: "#555", border: "#666", font: "#777"))

      expect(described_class.generate_map(:background)).to eq(__default: "#BDBDBD", test1: "#000", test2: "#222", test3: "#555")
      expect(described_class.generate_map(:border)).to eq(__default: "#9E9E9E", test1: "#111", test2: "#333", test3: "#666")
      expect(described_class.generate_map(:font)).to eq(__default: "#BDBDBD", test1: "#ccc", test2: "#444", test3: "#777")
    end
  end

  describe "#initialize" do
    context "when all attributes are given" do
      it "creates a new Color instance" do
        color = described_class.new(layer_name, &create_block)

        expect(color.layer_name).to eq layer_name
        expect(color.background).to eq "#000"
        expect(color.border).to eq "#111"
        expect(color.font).to eq "#ccc"
      end

      it "registers the color" do
        color = described_class.new(layer_name, &create_block)

        expect(described_class.fetch(layer_name)).to eq color
      end
    end

    context "when any of the attributes other than `font` are not given" do
      it "raises an ArgumentError" do
        expect do
          described_class.new(layer_name) do
            background "blue"
            font "yellow"
          end
        end.to raise_error(ArgumentError, "color: no `border` given")

        expect do
          described_class.new(layer_name) do
            border "black"
            font "white"
          end
        end.to raise_error(ArgumentError, "color: no `background` given")
      end
    end
  end

  describe "#highlight" do
    it "updates the highlight settings" do
      color = described_class.new(layer_name, &create_block(background: "#222", border: "#333", font: "#444"))

      new_background = "#aaa"
      new_border = "#bbb"
      new_font = "#ccc"

      color.highlight(background: new_background, border: new_border, font: new_font)

      expect(color.settings[:highlight]).to eq(
        background: new_background,
        border: new_border,
        font: new_font
      )
    end
  end
end
