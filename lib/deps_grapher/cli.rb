# frozen_string_literal: true

module DepsGrapher
  class Cli
    include Logging

    STATUS_SUCCESS = 0
    STATUS_FAILURE = 1
    private_constant :STATUS_SUCCESS, :STATUS_FAILURE

    class << self
      def run!(command)
        new(command).run!
      end
    end

    def initialize(command)
      @command = command
    end

    def run!
      @command.run!
      STATUS_SUCCESS
    rescue StandardError => e
      error { e.backtrace.unshift(e.message).join("\n") }
      STATUS_FAILURE
    end
  end
end
