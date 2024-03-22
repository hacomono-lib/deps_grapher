# frozen_string_literal: true

module DepsGrapher
  class DSL
    def initialize(obj)
      @obj = obj
    end

    def respond_to_missing?(symbol, include_private = false)
      ["#{symbol}=", symbol].each do |method_name|
        return true if @obj.respond_to?(method_name)
      end

      super
    end

    private

    def method_missing(symbol, *args, &block)
      ["#{symbol}=", symbol].each do |method_name|
        next unless @obj.respond_to?(method_name)

        parameters = @obj.method(method_name).parameters

        return @obj.send(method_name) if parameters.empty?

        if parameters.size == 1
          parameter = parameters.first
          case parameter[0]
          when :req, :opt
            return @obj.send(method_name, args.first.freeze)
          when :block
            return @obj.send(method_name, &block)
          else
            raise ArgumentError, "unsupported parameter type: #{parameter[0]}"
          end
        end

        next unless parameters.size == 2

        arg_type_1st, arg_type_2nd = parameters.flat_map(&:first)
        return @obj.send(method_name, args.first.freeze, &block) if %i[req opt].include?(arg_type_1st) && arg_type_2nd == :block

        raise ArgumentError, "unsupported parameter types: #{arg_type_1st}, #{arg_type_2nd}"
      end

      super
    end
  end
end
