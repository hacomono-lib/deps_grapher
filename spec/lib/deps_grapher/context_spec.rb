# frozen_string_literal: true

RSpec.describe DepsGrapher::Context do
  let(:config) { instance_double(DepsGrapher::Configuration) }
  let(:context) { described_class.new(config) }

  describe "#clean_dir!" do
    before do
      allow(FileUtils).to receive(:rm_rf)
      allow(config).to receive(:cache_dir)
      allow(config).to receive(:output_dir)
    end

    context "when @config.clean is true" do
      it "removes cache_dir and output_dir" do
        allow(config).to receive(:clean).and_return(true)
        context.clean_dir!
        expect(FileUtils).to have_received(:rm_rf).once
      end
    end

    context "when @config.clean is false" do
      it "does not remove any directories" do
        allow(config).to receive(:clean).and_return(false)
        context.clean_dir!
        expect(FileUtils).not_to have_received(:rm_rf)
      end
    end
  end

  describe "#generate_graphile" do
    let(:generator) { instance_double(DepsGrapher::Graphile::Generator) }

    before do
      allow(DepsGrapher::Graphile::Generator).to receive(:new).and_return(generator)
      allow(generator).to receive(:call)
    end

    it "calls Graphile::Generator with the correct arguments" do
      dest = "destination"
      context.generate_graphile(dest)
      expect(DepsGrapher::Graphile::Generator).to have_received(:new).with(config)
      expect(generator).to have_received(:call).with(dest)
    end
  end

  describe "#create_writer" do
    let(:html_writer) { instance_double(DepsGrapher::HtmlWriter) }

    before do
      allow(DepsGrapher::HtmlWriter).to receive(:new).and_return(html_writer)
      allow(config).to receive(:output_dir)
    end

    it "creates a new HtmlWriter instance" do
      expect(context.create_writer).to eq html_writer
      expect(DepsGrapher::HtmlWriter).to have_received(:new).with(config.output_dir)
    end
  end

  describe "#generate_temp_graphile" do
    before do
      allow(context).to receive(:generate_graphile)
    end

    it "calls generate_graphile with nil" do
      context.generate_temp_graphile
      expect(context).to have_received(:generate_graphile).with(nil)
    end
  end

  describe "#create_visualizer" do
    let(:downloader) { instance_double(DepsGrapher::Visualizer::Downloader) }

    before do
      expect(DepsGrapher::Visualizer::Downloader).to receive(:new).with("output_dir").and_return(downloader)
      allow(config).to receive(:output_dir).and_return("output_dir")
      allow(config).to receive(:visualizer).and_return("cy:klay")
      allow(config).to receive(:visualizer_options).and_return({ layers: [] })
    end

    it "creates a new Visualizer instance" do
      expect(context.create_visualizer).to be_an_instance_of DepsGrapher::Cytoscape::Klay
    end
  end

  describe "#create_graph" do
    before do
      allow(DepsGrapher::Graph).to receive(:new)
      allow(DepsGrapher::NullGraph).to receive(:new)
      allow(config).to receive(:target_path)
    end

    context "when target_path is not nil" do
      it "creates a new Graph instance" do
        allow(config).to receive(:target_path).and_return("path")
        context.create_graph
        expect(DepsGrapher::Graph).to have_received(:new)
      end
    end

    context "when target_path is nil" do
      it "creates a new NullGraph instance" do
        allow(config).to receive(:target_path).and_return(nil)
        context.create_graph
        expect(DepsGrapher::NullGraph).to have_received(:new)
      end
    end
  end
end
