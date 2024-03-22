# frozen_string_literal: true

RSpec.describe DepsGrapher::Cli do
  let(:command) { instance_double("Command") }
  let(:cli) { described_class.new(command) }

  include_context "logging"

  describe ".run!" do
    it "creates a new instance and runs it" do
      expect(command).to receive(:run!).and_return(0)
      expect(described_class.run!(command)).to eq 0
    end
  end

  describe "#run!" do
    context "when command succeeds" do
      before do
        allow(command).to receive(:run!)
      end

      it "returns success status" do
        expect(cli.run!).to eq 0
      end
    end

    context "when command fails" do
      before do
        allow(command).to receive(:run!).and_raise StandardError, "error occurred"
      end

      it "returns failure status" do
        expect(cli.run!).to eq 1
        expect(log_messages).to include("error occurred")
      end
    end
  end
end
