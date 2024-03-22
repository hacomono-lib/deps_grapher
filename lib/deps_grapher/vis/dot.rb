# frozen_string_literal: true

require_relative "../vis"

module DepsGrapher
  class Vis
    class Dot < self
      command_option "vis:dot"

      private

      def shape
        :dot
      end
    end
  end
end
