# frozen_string_literal: true

RSpec.describe DepsGrapher::AstProcessor do
  let(:file_path) { nil }
  let(:graph) { DepsGrapher::Graph.new }
  let(:event_processors) { {} }
  let(:advanced_const_resolver) { nil }
  let(:ignore_errors) { [true, false].sample }
  let(:lib_dir) { File.expand_path(File.join("..", "..", "..", "lib"), __dir__) }

  include_context "logging"

  before do
    value_lib_dir = lib_dir
    DepsGrapher::Layer.new do
      name :test

      source do
        root File.join(value_lib_dir)
      end

      color do
        background "black"
        border "black"
        font "black"
      end
    end
  end

  describe "#call" do
    it "parses the file and processes the AST" do
      expect do
        Dir.glob(File.join(lib_dir, "**", "*.rb")).sort.each do |file_path|
          described_class.new(file_path, graph, event_processors, advanced_const_resolver, ignore_errors).call
        end
      end.not_to raise_error
    end

    context "when use event processors" do
      it "calls the event processors" do
        results = []
        event_processors = {
          /DepsGrapher::Cli/ => [:const_name, ->(event) { results << "Found #{event.const_name} at #{event.location}" }],
          "DepsGrapher::Layer" => [:const_name, ->(event) { results << "Found layer #{event.key}" }],
          "method_found.DepsGrapher::Visualizer::Registry.register" => [:key, ->(event) { results << "event key is #{event.key}" }]
        }

        Dir.glob(File.join(lib_dir, "**", "*.rb")).sort.each do |file_path|
          described_class.new(file_path, graph, event_processors, advanced_const_resolver, ignore_errors).call
        end

        expect(results.join("\n")).to satisfy do
          _1.match?(/Found DepsGrapher::Cli at .+/) &&
            _1.match?(/Found layer (?:const|method)_found\.DepsGrapher::Layer(\.(?:new|extract_name!|exist\?))?/) &&
            _1.match?(/event key is method_found.DepsGrapher::Visualizer::Registry\.register/)
        end
      end
    end

    context "when use advanced const resolver" do
      context "with ignore_errors is true" do
        it "resolves the advanced const" do
          called = false
          advanced_const_resolver = proc do |_|
            called = true
            nil
          end

          Dir.glob(File.join(lib_dir, "**", "*.rb")).sort.each do |file_path|
            described_class.new(file_path, graph, event_processors, advanced_const_resolver, true).call
          end

          expect(called).to eq true
        end
      end

      context "with ignore_errors is false" do
        it "raises SourceLocationNotFound" do
          called = false
          advanced_const_resolver = proc do |_|
            called = true
            "Test"
          end

          expect do
            Dir.glob(File.join(lib_dir, "**", "*.rb")).sort.each do |file_path|
              described_class.new(file_path, graph, event_processors, advanced_const_resolver, false).call
            end
          end.to raise_error DepsGrapher::SourceLocationNotFound, "source location not found for Test"

          expect(called).to eq true
        end
      end
    end
  end
end
