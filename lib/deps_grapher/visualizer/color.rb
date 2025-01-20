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
          generate_random_colors! if @background.nil? || @border.nil?
          assert!
          Registry.register layer_name, self
        else
          generate_random_colors!
          @layer_name = "random_#{layer_name}"
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
        @background ||= "##{SecureRandom.hex(3)}"
        @border ||= "##{SecureRandom.hex(3)}"
      end

      def assert!
        raise ArgumentError, "color: no `background` given" if background.blank?
        raise ArgumentError, "color: no `border` given" if border.blank?
        raise ArgumentError, "color: no `font` given" if font.blank?
      end
    end
  end
end
