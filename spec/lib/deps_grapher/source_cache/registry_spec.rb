# frozen_string_literal: true

RSpec.describe DepsGrapher::SourceCache::Registry do
  let(:root) { File.expand_path("../../../lib/deps_grapher", __dir__) }

  let(:cache_by_const_name) do
    {
      "DepsGrapher" => File.join(root, "source_cache.rb"),
      "DepsGrapher::SourceCache" => File.join(root, "source_cache.rb")
    }
  end

  let(:cache_by_location) do
    {
      File.join(root, "source_cache.rb") => "DepsGrapher::SourceCache"
    }
  end

  let(:cache_dir) { File.join(spec_tmp_dir, SecureRandom.hex) }

  include_context "logging"

  before do
    DepsGrapher.configure do |config|
      config.cache_dir = cache_dir
    end
    described_class.register cache_by_const_name, cache_by_location
  end

  describe ".fetch" do
    context "when the const name exists in the registry" do
      it "fetches the source location from the registry" do
        expect(described_class.fetch("DepsGrapher::SourceCache")).to eq File.join(root, "source_cache.rb")
      end
    end

    context "when the location exists in the registry" do
      it "fetches the const name from the registry" do
        expect(described_class.fetch(File.join(root, "source_cache.rb"))).to eq "DepsGrapher::SourceCache"
      end
    end

    context "when the name does not exist in the registry" do
      it "raises a SourceCacheNotFound error" do
        expect { described_class.fetch("non_existing_name") }.to raise_error(DepsGrapher::SourceCacheNotFound)
      end
    end
  end

  describe ".key?" do
    context "when the key exists in the registry" do
      it "returns true" do
        expect(described_class.key?("DepsGrapher::SourceCache")).to eq true
      end
    end

    context "when the key does not exist in the registry" do
      it "returns false" do
        expect(described_class.key?("non_existing_name")).to eq false
      end
    end
  end

  describe ".persist_cache!" do
    let(:cache_file) { File.expand_path("source_cache", cache_dir) }

    after do
      FileUtils.rm_f(cache_file)
    end

    it "persists the registry to a file" do
      expect { described_class.persist_cache!("source_cache") }.not_to raise_error
      expect(File.exist?(cache_file)).to eq true
    end
  end

  describe ".restore_cache!" do
    let(:cache_file) { File.expand_path("source_cache", cache_dir) }

    after do
      FileUtils.rm_f(cache_file)
    end

    context "when the file does not exist" do
      it "returns false" do
        described_class.restore_cache!("source_cache")
        expect(described_class.restored_cache?).to eq false
      end
    end

    context "when the file exists" do
      before do
        described_class.persist_cache!("source_cache")
      end

      it "restores the registry from a file" do
        described_class.restore_cache!("source_cache")
        expect(described_class.restored_cache?).to eq true
        expect(described_class.fetch("DepsGrapher::SourceCache")).to eq File.join(root, "source_cache.rb")
        expect(described_class.fetch(File.join(root, "source_cache.rb"))).to eq "DepsGrapher::SourceCache"
      end
    end
  end
end
