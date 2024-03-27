# frozen_string_literal: true

RSpec.describe DepsGrapher::Command::Analyzer do
  let(:analyzer) { described_class.new(file_paths, context) }
  let(:file_paths) { [] }
  let(:context) { instance_double(DepsGrapher::Context) }

  include_context "logging"

  describe "#run!" do
    context "when file_paths is empty" do
      it "does not analyze" do
        analyzer.run!
        expect(log_messages).to include "No files to analyze"
      end
    end

    context "when file_paths is not empty" do
      let(:file_paths) do
        [
          File.expand_path(File.join("..", "..", "..", "..", "lib", "deps_grapher", "command", "analyzer.rb"), __dir__),
          File.join("..", "not_exist.rb")
        ]
      end
      let(:writer) { instance_double(DepsGrapher::HtmlWriter, path: File.join(spec_tmp_dir, "html", "index.html")) }
      let(:visualizer) { instance_double(DepsGrapher::Vis::Box) }
      let(:graph) { instance_double(DepsGrapher::Graph) }
      let(:source_path) { nil }
      let(:target_path) { nil }

      before do
        layer = DepsGrapher::Layer.new do
          name :test
          source do
            root File.expand_path(File.join("..", "..", "..", "..", "lib", "deps_grapher", "command"), __dir__)
            glob_pattern "analyzer.rb"
          end
          color do
            background "white"
            border "black"
            font "black"
          end
        end

        DepsGrapher::SourceCache.register! layer.name, layer.source

        allow(visualizer).to receive(:accept!)
        allow(visualizer).to receive(:render).and_return("html string")
        allow(writer).to receive(:write).with("html string").and_return(1234)
        allow(context).to receive(:clean_dir!)
        allow(context).to receive(:event_processors).and_return({})
        allow(context).to receive(:advanced_const_resolver)
        allow(context).to receive(:ignore_errors)
        allow(context).to receive(:create_writer).and_return(writer)
        allow(context).to receive(:create_visualizer).and_return(visualizer)
        allow(context).to receive(:create_graph).and_return(graph)
        allow(context).to receive(:source_path).and_return(source_path)
        allow(context).to receive(:target_path).and_return(target_path)
      end

      it "can analyze" do
        expect(context).to receive(:clean_dir!)
        expect(context).to receive(:event_processors)
        expect(context).to receive(:advanced_const_resolver)
        expect(context).to receive(:ignore_errors)
        expect(context).to receive(:create_writer)
        expect(context).to receive(:create_visualizer)

        analyzer.run!

        expect(log_messages).to include "Writing to #{writer.path} (1234 bytes)"
        expect(log_messages).to include "Run `open #{writer.path}` to view the graph"
      end

      context "when target_path is set" do
        let(:target_path) { described_class.name }

        it "can analyze" do
          expect(graph).to receive(:find_path).with(nil, instance_of(DepsGrapher::Matcher)).and_return([[], []])

          analyzer.run!
          expect(log_messages).to include "Writing to #{writer.path} (1234 bytes)"
          expect(log_messages).to include "Run `open #{writer.path}` to view the graph"
        end

        context "when source_path is set" do
          let(:source_path) { described_class.name }

          it "can analyze" do
            expect(graph).to receive(:find_path).with(instance_of(DepsGrapher::Matcher), instance_of(DepsGrapher::Matcher)).and_return([[], []])

            analyzer.run!
            expect(log_messages).to include "Writing to #{writer.path} (1234 bytes)"
            expect(log_messages).to include "Run `open #{writer.path}` to view the graph"
          end
        end
      end
    end
  end
end
