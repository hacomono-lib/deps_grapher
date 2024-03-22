# frozen_string_literal: true

module DepsGrapher
  module Visualizer
    class JsOption
      class Function
        def initialize(body:, args: nil)
          @args = args
          @body = body
        end

        def as_json(*)
          <<~JS.split(/$/).map(&:strip).compact_blank.join(";")
            function(#{Array(@args).join(", ")}) {
              #{@body}
            }
          JS
        end
      end

      def initialize(hash = {})
        @hash = hash
      end

      def add_function(name:, body:, args: nil)
        @hash[name] = Function.new(args: args, body: body)
        self
      end

      def as_json(*)
        @hash.as_json
      end

      def to_s
        as_json.to_json.gsub('"function', "function").gsub('}"', "}")
      end
    end
  end
end
