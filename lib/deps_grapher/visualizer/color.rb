# frozen_string_literal: true

require_relative "color/registry"

module DepsGrapher
  module Visualizer
    class Color
      class << self
        def fetch(layer_name)
          Registry.fetch layer_name
        end
        alias [] fetch

        def generate_map(type)
          Registry.all.to_h { |color| [color.layer_name, color.send(type)] }
        end
      end

      attr_accessor :layer_name, :background, :border, :font, :arrow, :settings

      def initialize(layer_name, &block)
        @layer_name = layer_name
        @font = "#ffffff"
        @has_block = block_given?

        if @has_block
          DSL.new(self).instance_eval(&block)
          assert!
          Registry.register layer_name, self
        else
          @layer_name = "random_#{layer_name}"
          assert!
        end

        @settings = {
          background: background,
          border: border,
          font: font,
          highlight: {
            background: background,
            border: border,
            font: font
          }
        }
      end

      def highlight(background:, border:, font: "#ffffff")
        @settings[:highlight] = {
          background: background,
          border: border,
          font: font
        }

        self
      end

      private

      def generate_random_colors!
        require "securerandom"
        @background = @background.presence || "##{SecureRandom.hex(3)}"
        @border = @border.presence || "##{SecureRandom.hex(3)}"
      end

      def assert!
        if @has_block
          # In block mode, generate random colors for missing attributes
          @background = "##{SecureRandom.hex(3)}" if @background.blank?
          @border = "##{SecureRandom.hex(3)}" if @border.blank?
        else
          # In non-block mode, generate both colors if none are provided
          generate_random_colors! if @background.blank? && @border.blank?
        end
        raise ArgumentError, "color: no `font` given" if @font.blank?
      end
    end
  end
end
