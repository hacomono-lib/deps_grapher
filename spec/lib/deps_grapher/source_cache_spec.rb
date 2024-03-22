# frozen_string_literal: true

RSpec.describe DepsGrapher::SourceCache do
  let(:source_cache) { described_class.new(:test, source) }
  let(:source) do
    value = root
    DepsGrapher::Source.new(:test) do
      root value
      include_pattern File.join("*", "source_cache.rb")
    end
  end
  let(:root) { File.expand_path(File.join("..", "..", "..", "lib", "deps_grapher"), __dir__) }

  include_context "logging"

  before do
    allow(described_class::Registry).to receive(:register)
  end

  describe "#register!" do
    it "calls load! and return value like a tuple" do
      source_cache.register!

      cache_by_const_name = {
        "DepsGrapher" => File.join(root, "source_cache.rb"),
        "DepsGrapher::SourceCache" => File.join(root, "source_cache.rb")
      }

      cache_by_location = {
        File.join(root, "source_cache.rb") => "DepsGrapher::SourceCache"
      }

      expect(described_class::Registry).to have_received(:register).with(cache_by_const_name, cache_by_location).once
    end
  end

  describe "logging" do
    it "logs messages" do
      source_cache.register!
      expect(log_messages).to match(/Collecting `test` layer by glob_pattern:/)
      expect(log_messages).to match(%r{Found \d+ modules/classes, \d+ locations in `test` layer})
    end
  end
end
