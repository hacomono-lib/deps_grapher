# frozen_string_literal: true

module DepsGrapher
  class HtmlWriter
    attr_reader :path

    def initialize(output_dir)
      FileUtils.mkdir_p output_dir
      @path = File.join output_dir, "index.html"
    end

    def write(content)
      File.write path, content
    end
  end
end
