# frozen_string_literal: true

RSpec.describe DepsGrapher::Visualizer do
  describe ".fetch" do
    it "calls Registry.fetch with the given name" do
      allow(DepsGrapher::Visualizer::Registry).to receive(:fetch).with("cy:klay").and_return("some value")
      expect(described_class.fetch("cy:klay")).to eq "some value"
      expect(DepsGrapher::Visualizer::Registry).to have_received(:fetch).with("cy:klay").once
    end
  end
end
