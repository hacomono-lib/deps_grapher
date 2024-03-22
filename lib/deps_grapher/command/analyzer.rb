# frozen_string_literal: true

module DepsGrapher
  module Command
    class Analyzer
      include Logging

      def initialize(file_paths, context)
        @file_paths = file_paths
        @context = context
      end

      def run!
        if file_paths.empty?
          warn { "No files to analyze" }
          return
        end

        clean_dir!
        analyze!
        visualize!
      rescue TargetNodeNotFound => e
        info { e.message }
      end

      private

      attr_reader :file_paths, :context

      def clean_dir!
        context.clean_dir!
      end

      def analyze!
        file_paths.each do |file_path|
          file_path = File.expand_path file_path

          unless File.exist?(file_path)
            warn { "Skipping #{file_path}" }
            next
          end

          ast_processor = AstProcessor.new(
            file_path,
            graph,
            context.event_processors,
            context.advanced_const_resolver,
            context.ignore_errors
          )

          ast_processor.call
        end
      end

      def visualize!
        writer = context.create_writer
        visualizer = context.create_visualizer
        visualizer.accept!(*extract_graph_elements)
        bytesize = writer.write visualizer.render

        info { "Writing to #{writer.path} (#{bytesize} bytes)" }
        info { "Run `open #{writer.path}` to view the graph" }
      end

      def extract_graph_elements
        if context.target_path
          source_path_matcher = nil
          source_path_matcher = Matcher.new(context.source_path) if context.source_path.present?

          target_path_matcher = Matcher.new(context.target_path)

          message = []
          message << "Searching paths"
          message << "from `#{source_path_matcher}`" if source_path_matcher
          message << "to `#{target_path_matcher}`"

          info { message.join(" ") }
          graph.find_path source_path_matcher, target_path_matcher
        else
          [Node.all, Edge.all]
        end
      end

      def graph
        @graph ||= context.create_graph
      end
    end
  end
end
