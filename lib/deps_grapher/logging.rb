# frozen_string_literal: true

module DepsGrapher
  module Logging
    def info(&block)
      DepsGrapher.logger.info(&block)
    end

    def warn(&block)
      DepsGrapher.logger.warn(&block)
    end

    def error(&block)
      DepsGrapher.logger.error(&block)
    end

    def verbose(&block)
      DepsGrapher.logger.info(&block) if DepsGrapher.config.verbose
    end
  end
end
