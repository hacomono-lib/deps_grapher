# frozen_string_literal: true

require "readline"
require "fileutils"

module DepsGrapher
  module Command
    class Init
      include Logging

      def initialize(context)
        @context = context
      end

      def run!
        dest = File.expand_path("graphile.rb")

        return if File.exist?(dest) && !ask_yes_no("Overwrite `#{dest}`?")

        context.generate_graphile dest

        info { "\n`#{dest}` was created." }
        info { "Please edit the configuration file." }
        info { "Run `bundle exec deps_grapher -c #{File.basename(dest)}`." }
      end

      private

      attr_reader :context

      def ask_yes_no(question)
        stty_save = `stty -g`.chomp
        trap("INT") do
          system "stty", stty_save
          exit
        end

        while (input = Readline.readline("#{question} (y/n): ", true))
          case input
          when "y"
            return true
          when "n"
            return false
          end
        end
      end
    end
  end
end
