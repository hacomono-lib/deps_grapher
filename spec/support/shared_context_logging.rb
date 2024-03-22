# frozen_string_literal: true

RSpec.shared_context "logging" do
  let(:io) { StringIO.new }
  let(:log_messages) { io.string }

  around do |example|
    current = DepsGrapher.config.logger
    DepsGrapher.config.logger = Logger.new(io)
    DepsGrapher.config.verbose = true
    example.run
    DepsGrapher.config.logger = current
    DepsGrapher.config.verbose = false
  end
end
