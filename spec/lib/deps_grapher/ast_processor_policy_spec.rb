# frozen_string_literal: true

# rubocop:disable Lint/AmbiguousRegexpLiteral

RSpec.describe DepsGrapher::AstProcessorPolicy do
  let(:context) { instance_double(DepsGrapher::Context, event_processors: {}, advanced_const_resolver: nil) }

  describe "#include_const" do
    it "adds an event processor that marks processing for a const" do
      described_class.new(context) do
        include_const /test/
      end

      expect(context.event_processors).to have_key(/test/)
      type, processor = context.event_processors[/test/]
      expect(type).to eq :const_name
      expect(processor.to_s).to include "&:processing!"
    end
  end

  describe "#exclude_const" do
    it "adds an event processor that marks skipping processing for a const" do
      described_class.new(context) do
        exclude_const /test/
      end

      expect(context.event_processors).to have_key(/test/)
      type, processor = context.event_processors[/test/]
      expect(type).to eq :const_name
      expect(processor.to_s).to include "&:skip_processing!"
    end
  end

  describe "#include_location" do
    it "adds an event processor that marks processing for a location" do
      described_class.new(context) do
        include_location /test/
      end

      expect(context.event_processors).to have_key(/test/)
      type, processor = context.event_processors[/test/]
      expect(type).to eq :location
      expect(processor.to_s).to include "&:processing!"
    end
  end

  describe "#exclude_location" do
    it "adds an event processor that marks skipping processing for a location" do
      described_class.new(context) do
        exclude_location /test/
      end

      expect(context.event_processors).to have_key(/test/)
      type, processor = context.event_processors[/test/]
      expect(type).to eq :location
      expect(processor.to_s).to include "&:skip_processing!"
    end
  end

  describe "#advanced_const_resolver" do
    it "sets the advanced const resolver" do
      block = proc { "test" }
      expect(context).to receive(:advanced_const_resolver=).with(block)
      described_class.new(context) do
        advanced_const_resolver(&block)
      end
    end

    it "raises an error if no block or callable is provided" do
      expect do
        described_class.new(context) do
          advanced_const_resolver
        end
      end.to raise_error(ArgumentError, "You must provide a block or callable")
    end

    it "raises an error if the provided object does not respond to #call" do
      expect do
        described_class.new(context) do
          advanced_const_resolver "test"
        end
      end.to raise_error(ArgumentError, "The provided object must respond to #call")
    end
  end
end

# rubocop:enable Lint/AmbiguousRegexpLiteral
