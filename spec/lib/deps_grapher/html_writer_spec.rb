# frozen_string_literal: true

RSpec.describe DepsGrapher::HtmlWriter do
  let(:html_writer) { described_class.new output_dir }
  let(:output_dir) { File.join(spec_tmp_dir, "output") }

  describe "#write" do
    let(:html) { "<html><body><h1>Hello, World!</h1></body></html>" }

    it "writes html to file" do
      expect(html_writer.write(html)).to eq html.bytesize
      expect(File.read(html_writer.path)).to eq html
    end
  end
end
