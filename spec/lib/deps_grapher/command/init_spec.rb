# frozen_string_literal: true

RSpec.describe DepsGrapher::Command::Init do
  let(:context) { instance_double(DepsGrapher::Context) }
  let(:init) { described_class.new(context) }

  describe "#run!" do
    let(:dest) { File.expand_path("graphile.rb") }

    before do
      allow(context).to receive(:generate_graphile)
      allow(init).to receive(:info)
    end

    context "when file does not exist" do
      before do
        allow(File).to receive(:exist?).with(dest).and_return(false)
      end

      it "generates the file and logs the message" do
        expect(context).to receive(:generate_graphile).with(dest)
        expect(init).to receive(:info).exactly(3).times
        init.run!
      end
    end

    context "when file exists and user agrees to overwrite" do
      before do
        allow(File).to receive(:exist?).with(dest).and_return(true)
        allow(init).to receive(:ask_yes_no).and_return(true)
      end

      it "overwrites the file and logs the message" do
        expect(context).to receive(:generate_graphile).with(dest)
        expect(init).to receive(:info).exactly(3).times
        init.run!
      end
    end

    context "when file exists and user does not agree to overwrite" do
      before do
        allow(File).to receive(:exist?).with(dest).and_return(true)
        allow(init).to receive(:ask_yes_no).and_return(false)
      end

      it "does not overwrite the file and does not log the message" do
        expect(context).not_to receive(:generate_graphile)
        expect(init).not_to receive(:info)
        init.run!
      end
    end
  end
end
