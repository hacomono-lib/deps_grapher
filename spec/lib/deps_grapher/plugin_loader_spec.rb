# frozen_string_literal: true

RSpec.describe DepsGrapher::PluginLoader do
  describe ".load!" do
    context "when plugin directory is blank" do
      it "does not call `Dir.glob`" do
        allow(Dir).to receive(:glob).and_call_original
        described_class.load!("")
        expect(Dir).not_to have_received(:glob)
      end
    end

    context "when plugin directory does not exist" do
      it "does not call `Dir.glob`" do
        allow(Dir).to receive(:glob).and_call_original
        described_class.load!(File.join(spec_tmp_dir, "plugins", "not_exist"))
        expect(Dir).not_to have_received(:glob)
      end
    end

    context "when plugin directory exists" do
      let(:plugin_dir) { File.join(spec_tmp_dir, "plugins") }

      around do |example|
        FileUtils.mkdir_p plugin_dir
        File.write File.join(plugin_dir, "custom_visualizer.rb"), <<~PLUGIN
          module DepsGrapher
            class CustomVisualizer < Visualizer::Base
              command_option "custom"
            end

            Visualizer::Registry.class_eval { registry.delete("custom") }
          end
        PLUGIN

        example.run

        FileUtils.rm_rf plugin_dir
      end

      it "calls `Dir.glob`" do
        allow(Dir).to receive(:glob).and_call_original
        described_class.load!(plugin_dir)
        expect(Dir).to have_received(:glob)

        expect(DepsGrapher.const_defined?(:CustomVisualizer)).to be true
        DepsGrapher.module_eval { remove_const :CustomVisualizer }
      end
    end
  end
end
