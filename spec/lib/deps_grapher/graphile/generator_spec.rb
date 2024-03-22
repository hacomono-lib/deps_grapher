# frozen_string_literal: true

RSpec.describe DepsGrapher::Graphile::Generator do
  let(:config) { DepsGrapher::Configuration.new }
  let(:generator) { described_class.new config }

  describe "#call" do
    before do
      config.cache_dir = File.join spec_tmp_dir, "cache"
      FileUtils.mkdir_p config.cache_dir
    end

    context "when dest is provided" do
      it "writes the template to the dest and returns the dest" do
        file_path = File.join spec_tmp_dir, SecureRandom.hex
        dest = generator.call file_path
        expect(dest).to eq file_path
        expect(File.exist?(dest)).to eq true
      end
    end

    context "when dest is not provided" do
      it "writes the template to a tempfile and returns the path of the tempfile" do
        dest = generator.call nil
        expect(File.basename(dest)).to match(/^graphile_generator#{Date.current.strftime("%Y%m%d")}-.+/)
        expect(File.exist?(dest)).to eq true
      end
    end
  end
end
