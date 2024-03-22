# frozen_string_literal: true

RSpec.describe DepsGrapher::Input do
  let(:input) { described_class.new(config) }
  let(:config) do
    DepsGrapher::Configuration.new.tap do |c|
      c.merge!(
        clean: clean,
        cache_dir: cache_dir
      )
    end
  end
  let(:clean) { [true, false].sample }
  let(:cache_dir) { File.join(spec_tmp_dir, "cache", SecureRandom.hex) }

  include_context "logging"

  describe "#files" do
    let(:root) { File.expand_path(File.join("..", "..", "..", "lib", "deps_grapher"), __dir__) }
    let(:layers) { %i[input layer] }

    before do
      value_root = root

      config.layer do
        name :input
        source do
          root value_root
          include_pattern(/input\.rb/)
        end
        color do
          background "blue"
          border "black"
          font "white"
        end
      end

      config.layer do
        name :layer
        source do
          root value_root
          glob_pattern "layer.rb"
        end
        color do
          background "red"
          border "green"
          font "yellow"
        end
      end

      config.visualizer_options[:layers] = layers
    end

    it "returns all files from target directory" do
      expect(input.files).to eq([File.join(root, "input.rb"), File.join(root, "layer.rb")])
    end

    context "when one of layers is not visible" do
      let(:layers) { %i[input] }

      it "returns files only from visible layers" do
        expect(input.files).to eq([File.join(root, "input.rb")])
      end
    end
  end
end
