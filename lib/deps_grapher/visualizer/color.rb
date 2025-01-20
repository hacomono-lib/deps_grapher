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

        def random
          new(SecureRandom.hex(4))
        end
      end

      attr_accessor :layer_name, :background, :border, :font, :arrow, :settings

      def initialize(layer_name, &block)
        if block_given?
          DSL.new(self).instance_eval(&block)
        else
          generate_random_colors!
        end

        @layer_name = layer_name
        @font ||= "#fff"

        assert!

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

        Registry.register layer_name, self
      end

      def highlight(background:, border:, font: "#fff")
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
        @background = "##{SecureRandom.hex(3)}"
        @border = "##{SecureRandom.hex(3)}"
        @font = "#ffffff" # Keep font white for readability
      end

      def assert!
        raise ArgumentError, "color: no `background` given" if background.blank?
        raise ArgumentError, "color: no `border` given" if border.blank?
        raise ArgumentError, "color: no `font` given" if font.blank?
      end
    end
  end
end
