# frozen_string_literal: true

module DepsGrapher
  module PluginDSL
    def with_plugin(&block)
      plugin_dir = DepsGrapher.config.plugin_dir
      return if plugin_dir.blank? || !File.directory?(plugin_dir)

      block.call plugin_dir
    end
  end
end
