# frozen_string_literal: true

require "simplecov"
SimpleCov.start do
  add_filter File.join("", "vendor", "")
  add_filter File.join("", "spec", "")
end

require "deps_grapher"
require "webmock/rspec"

Dir[File.expand_path(File.join("support", "**", "*.rb"), __dir__)].sort.each { |f| require f }

def spec_tmp_dir
  File.expand_path "tmp", __dir__
end

RSpec.configure do |config|
  config.define_derived_metadata do |meta|
    meta[:aggregate_failures] = true
  end

  config.before(:suite) do
    FileUtils.mkdir_p spec_tmp_dir
  end

  config.after do
    DepsGrapher::Visualizer::Color::Registry.send(:registry).tap do |registry|
      registry.each_key do |key|
        next if key == DepsGrapher::Layer::Default.name

        registry.delete(key)
      end
    end
    DepsGrapher::SourceCache::Registry.send(:registry).clear
    DepsGrapher::SourceCache::Registry.instance_variable_set(:@restored_cache, nil)
    DepsGrapher::Layer::Registry.send(:registry).clear
    DepsGrapher::Node.send(:registry).clear
    DepsGrapher::Node.instance_variable_set(:@guid, nil)
    DepsGrapher::Edge.send(:registry).clear
    DepsGrapher::Event.send(:registry).clear

    DepsGrapher::AstProcessor.processed.clear
    DepsGrapher::AstProcessor.event_processed.clear

    FileUtils.rm_rf File.join(spec_tmp_dir, "*")
  end

  config.after(:suite) do
    FileUtils.rm_rf spec_tmp_dir
  end

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random
end
