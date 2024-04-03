# frozen_string_literal: true

module DepsGrapher
  class SourceCache
    class ClassNameExtractor < Parser::AST::Processor
      class << self
        def cache
          @cache ||= Set.new
        end
      end

      def initialize(&block)
        super()
        @block = block
      end

      def extract!(file_path)
        source_buffer = Parser::Source::Buffer.new(file_path)
        parser = Prism::Translation::Parser.new
        process parser.parse(source_buffer.read)
      end

      def on_module(node)
        const_node = node.children[0]
        name = extract_const_name const_node

        @namespace_stack ||= []
        @namespace_stack.push name

        super

        const_name = @namespace_stack.join("::")

        unless self.class.cache.include? const_name
          self.class.cache << const_name
          @block.call const_name, node.location.name.source_buffer.name
        end

        @namespace_stack.pop
      end
      alias on_class on_module

      private

      def extract_const_name(node)
        case node.type
        when :const
          base, name = *node
          if base.nil?
            name.to_s
          else
            [extract_const_name(base), name].compact.join "::"
          end
        else
          raise "unexpected node type: #{node.type}"
        end
      end
    end
  end
end
