# frozen_string_literal: true

RSpec.describe DepsGrapher::Configuration do
  let(:config) { described_class.new }

  include_context "logging"

  it "includes PluginDSL module" do
    expect(described_class.ancestors).to include(DepsGrapher::PluginDSL)
  end

  describe "#initialize" do
    it "initializes with default values" do
      expect(config.logger).to be_a(Logger)
      expect(config.visualizer).to eq(DepsGrapher::Visualizer::Registry.default_visualizer)
    end
  end

  describe "#available_visualizers" do
    it "returns available visualizers" do
      expect(config.available_visualizers).to eq(DepsGrapher::Visualizer::Registry.available_visualizers)
    end
  end

  describe "#input" do
    it "returns a new input" do
      expect(config.input).to be_a(DepsGrapher::Input)
    end
  end

  describe "#merge!" do
    it "merges options correctly" do
      options = { visualizer: "new_visualizer", verbose: true }
      config.merge!(options)
      expect(config.visualizer).to eq("new_visualizer")
      expect(config.verbose).to be true
    end
  end

  describe "#load!" do
    it "loads configuration file correctly" do
      config_path = File.join(spec_tmp_dir, "#{SecureRandom.hex}.rb")
      root = File.expand_path(File.join("..", "..", "..", "lib", "deps_grapher"), __dir__)
      File.write config_path, <<~RUBY
        plugin_dir "#{File.join(spec_tmp_dir, "plugins")}"

        visualizer "vis:dot"

        ast_processor_policy do

        end

        layer do
          name :vis
          source do
            root "#{root}"
            glob_pattern File.join("vis", "**", "*.rb")
          end
          color do
            background "blue"
            border "black"
            font "white"
          end
        end

        layer do
          name :cy
          source do
            root "#{root}"
            glob_pattern File.join("cytoscape", "**", "*.rb")
          end
          color do
            background "red"
            border "yellow"
            font "green"
          end
        end
      RUBY

      config.load!(config_path)
      expect(config.path).to eq(config_path)
      expect(config.visualizer).to eq "vis:dot"
      expect(config.layers.keys).to eq %i[vis cy]
    end

    it "raises error when file does not exist" do
      expect { config.load!("non_existent_file.rb") }.to raise_error(ArgumentError)
    end
  end

  describe "#load_plugin!" do
    before do
      allow(DepsGrapher::PluginLoader).to receive(:load!).and_return(nil)
    end

    it "loads plugins" do
      expect(DepsGrapher::PluginLoader).to receive(:load!).with(config.plugin_dir)
      config.load_plugin!
    end
  end

  describe "#context" do
    it "returns a new context" do
      expect(config.context).to be_a(DepsGrapher::Context)
    end

    it "returns the same context" do
      context = config.context
      expect(config.context).to be context
    end
  end
end
