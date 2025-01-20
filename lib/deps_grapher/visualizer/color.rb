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

        if block_given?
          DSL.new(self).instance_eval(&block)
          assert!  # Validate required attributes are set in the block
          Registry.register layer_name, self
        else
          generate_random_colors!
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
        if @background.blank? && @border.blank?
          generate_random_colors!
        else
          raise ArgumentError, "color: no `background` given" if @background.blank?
          raise ArgumentError, "color: no `border` given" if @border.blank?
        end
        raise ArgumentError, "color: no `font` given" if @font.blank?
      end
    end
  end
end
