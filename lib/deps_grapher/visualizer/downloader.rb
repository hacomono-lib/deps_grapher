# frozen_string_literal: true

module DepsGrapher
  module Visualizer
    class Downloader
      include Logging

      def initialize(download_dir)
        @download_dir = download_dir
      end

      def download(url, force: false)
        uri = URI.parse url
        file_name = File.basename uri.to_s
        file_path = File.join @download_dir, file_name

        FileUtils.rm_f file_path if force

        return if File.exist?(file_path)

        response = get_response uri

        raise "download error occurred: #{uri} (#{response.code})" if response.code.to_i != 200

        File.write file_path, response.body
      end

      private

      def get_response(uri)
        response = Net::HTTP.get_response uri
        if response["location"]
          uri.merge! response["location"]
          verbose { "Follow redirect to #{uri} to download library" }
          get_response uri
        else
          response
        end
      end
    end
  end
end
