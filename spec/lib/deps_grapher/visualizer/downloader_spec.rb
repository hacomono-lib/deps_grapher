# frozen_string_literal: true

RSpec.describe DepsGrapher::Visualizer::Downloader do
  let(:download_dir) { File.join(spec_tmp_dir, "downloader") }
  let(:downloader) { described_class.new(download_dir) }
  let(:url) { "https://example.com/file.txt" }
  let(:file_path) { File.join(download_dir, "file.txt") }

  include_context "logging"

  before do
    FileUtils.mkdir_p download_dir
    FileUtils.safe_unlink file_path
  end

  describe "#download" do
    context "when the download is successful" do
      let(:response_body) { "response body" }

      before do
        stub_request(:get, url).to_return(status: 200, body: response_body)
      end

      it "writes the response body to a file" do
        expect(downloader.download(url)).to eq response_body.size
        expect(File.read(file_path)).to eq response_body
      end
    end

    context "when the file already exists" do
      before do
        FileUtils.touch file_path
      end

      it "does not download the file again" do
        expect(downloader).not_to receive(:get_response)
        downloader.download(url)
      end
    end

    context "when the download fails" do
      let(:response_body) { "not found" }

      before do
        stub_request(:get, url).to_return(status: 404, body: response_body)
      end

      it "raises an error" do
        expect { downloader.download(url) }.to raise_error RuntimeError, "download error occurred: #{url} (404)"
      end
    end

    context "when the force option is true" do
      let(:response_body) { "response body" }

      before do
        FileUtils.touch file_path
      end

      it "downloads the file again" do
        expect(downloader).to receive(:get_response).and_return(double(code: "200", body: "response body"))
        expect(downloader.download(url, force: true)).to eq response_body.size
      end
    end

    context "when the location header is present" do
      let(:response_body) { "response body" }

      before do
        stub_request(:get, url).to_return(status: 302, headers: { "Location" => redirect_url })
      end

      context "when the location header is fqdn" do
        let(:redirect_url) { "https://example.redirect.com/redirected.txt" }

        before do
          stub_request(:get, redirect_url).to_return(status: 200, body: response_body)
        end

        it "follows the redirect and downloads the file" do
          expect(downloader.download(url)).to eq response_body.size
          expect(log_messages).to include("Follow redirect to https://example.redirect.com/redirected.txt to download library")
          expect(File.read(file_path)).to eq response_body
        end
      end

      context "when the location header is not fqdn" do
        let(:redirect_url) { "/redirected.txt" }

        before do
          stub_request(:get, /#{Regexp.escape(redirect_url)}/).to_return(status: 200, body: response_body)
        end

        it "follows the redirect and downloads the file" do
          expect(downloader.download(url)).to eq response_body.size
          expect(log_messages).to include("Follow redirect to https://example.com/redirected.txt to download library")
          expect(File.read(file_path)).to eq response_body
        end
      end
    end
  end
end
