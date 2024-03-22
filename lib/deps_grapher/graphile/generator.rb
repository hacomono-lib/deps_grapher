# frozen_string_literal: true

module DepsGrapher
  module Graphile
    class Generator
      def initialize(config)
        @config = config
      end

      def call(dest)
        if dest
          File.write dest, read_template(temp: false)
          return dest
        end

        path = nil

        # unlink this temp file by GC
        Tempfile.open("graphile_generator", config.cache_dir) do |f|
          f.write read_template(temp: true)
          path = f.path
        end

        path
      end

      private

      attr_reader :config

      def read_template(temp:)
        b = config.instance_eval { binding }
        ERB.new(File.read(resolve_path(temp)), trim_mode: "-").result(b)
      end

      def resolve_path(temp)
        file_name = temp ? "graphile.temp.erb" : "graphile.erb"
        File.expand_path(file_name, __dir__)
      end
    end
  end
end
