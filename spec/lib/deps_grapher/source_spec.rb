# frozen_string_literal: true

RSpec.describe DepsGrapher::Source do
  let(:source) { described_class.new(:test, &block) }
  let(:block) { nil }
  let(:root) { File.expand_path(File.join("..", "..", "..", "lib", "deps_grapher"), __dir__) }

  describe "#initialize" do
    context "when no block given" do
      it "raises an error" do
        expect { described_class.new :test }.to raise_error ArgumentError, /wrong number of arguments/
      end
    end

    context "when block given, but `root` is not set" do
      it "raises an error" do
        expect { described_class.new(:test) { glob_pattern "" } }.to raise_error ArgumentError, /source: no `root` given/
      end
    end

    context "when block given, and `root` is blank" do
      it "raises an error" do
        expect { described_class.new(:test) { root "" } }.to raise_error ArgumentError, /source: no `root` given/
      end
    end

    context "when block given, and `root` does not exist" do
      it "raises an error" do
        expect do
          described_class.new(:test) { root File.expand_path(File.join("not", "exist", "directory"), __dir__) }
        end.to raise_error ArgumentError, /source: directory not found/
      end
    end

    context "when block given, and `glob_pattern` is not set" do
      it "does not raise an error" do
        value = root
        expect(described_class.new(:test) do
          root value
        end).to(satisfy { |source| source.glob_pattern == [File.join(value, "**", "*.rb")] })
      end
    end

    context "when block given, and `glob_pattern` is blank" do
      it "does not raise an error" do
        value = root
        expect(described_class.new(:test) do
          root value
          glob_pattern ""
        end).to satisfy do |source|
          source.glob_pattern == [File.join(value, "**", "*.rb")]
        end
      end
    end

    context "when block given, and `glob_pattern` is set" do
      it "does not raise an error" do
        value = root
        expect(described_class.new(:test) do
          root value
          glob_pattern "source.rb"
        end).to satisfy do |source|
          source.glob_pattern == [File.join(value, "source.rb")]
        end
      end
    end

    context "when block given, and `glob_pattern` are set" do
      it "does not raise an error" do
        value = root
        expect(described_class.new(:test) do
          root value
          glob_pattern ["source.rb", "source_cache.rb"]
        end).to satisfy do |source|
          source.glob_pattern == [File.join(value, "source.rb"), File.join(value, "source_cache.rb")]
        end
      end
    end
  end

  describe "#files" do
    let(:block) do
      value = root
      proc do
        root value
      end
    end

    context "when no `include_pattern` and `exclude_pattern` given" do
      it "returns an array of files" do
        expect(source.files).to eq Dir.glob(File.join(root, "**", "*.rb")).sort.uniq
      end
    end

    context "when `include_pattern` given" do
      let(:block) do
        value = root
        proc do
          root value
          include_pattern File.join("*", "ast_*")
        end
      end

      it "returns an array of files" do
        expect(source.files).to eq [File.join(root, "ast_processor.rb"), File.join(root, "ast_processor_policy.rb")]
      end
    end

    context "when `include_pattern` with dot given" do
      let(:block) do
        value = root
        proc do
          root value
          include_pattern File.join("*", "ast_.*")
        end
      end

      it "returns an array of files" do
        expect(source.files).to eq [File.join(root, "ast_processor.rb"), File.join(root, "ast_processor_policy.rb")]
      end
    end

    context "when `exclude_pattern` given" do
      let(:block) do
        value = root
        proc do
          root value
          exclude_pattern File.join("*", "ast_*")
        end
      end

      it "returns an array of files" do
        excluded_files = [File.join(root, "ast_processor.rb"), File.join(root, "ast_processor_policy.rb")]
        expect(source.files).to eq Dir.glob(File.join(root, "**", "*.rb")).sort.uniq - excluded_files
      end
    end
  end

  unless Gem.win_platform?
    describe "#to_s" do
      let(:block) do
        value = root
        proc do
          root value
          glob_pattern "source.rb"
          include_pattern File.join("*", "visualizer")
          exclude_pattern File.join("*", "ast_*")
        end
      end

      it "returns a string representation of the object" do
        expect(source.to_s).to eq([
          "glob_pattern: [\"#{File.join(root, "source.rb")}\"]",
          "include_pattern: /\\A.*\\/visualizer\\z/",
          "exclude_pattern: /\\A.*\\/ast_.*\\z/"
        ].join(", "))
      end
    end
  end
end
