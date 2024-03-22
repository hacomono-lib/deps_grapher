# frozen_string_literal: true

require_relative "../vis"

module DepsGrapher
  class Vis
    class Box < self
      command_option "vis:box"

      private

      def font_color(_)
        "#fff"
      end

      def shape
        :box
      end
    end
  end
end
