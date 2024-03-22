# frozen_string_literal: true

module DepsGrapher
  class PluginLoader
    class << self
      def load!(plugin_dir)
        new(plugin_dir).load!
      end
    end

    private_class_method :new

    def initialize(plugin_dir)
      @plugin_dir = plugin_dir
    end

    def load!
      return if plugin_dir.blank? || !Dir.exist?(plugin_dir)

      Dir.glob(File.join(plugin_dir, "**", "*.rb")).sort.each do |file|
        require file
      end
    end

    private

    attr_reader :plugin_dir
  end
end
