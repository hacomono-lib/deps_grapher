# frozen_string_literal: true

RSpec.describe DepsGrapher::Visualizer::JsOption do
  let(:function_body) do
    <<~JS
      console.log("Hello, \\nWorld!")
      return true
    JS
  end
  let(:function_args) { %w[arg1 arg2] }

  describe "#initialize" do
    it "creates a new JsOption instance" do
      js_option = described_class.new

      expect(js_option).to be_a described_class
    end
  end

  describe "#add_function" do
    it "adds a new function to the hash" do
      js_option = described_class.new
      js_option.add_function(name: "testFunction", body: function_body, args: function_args)

      expect(js_option.instance_variable_get(:@hash)["testFunction"]).to be_a described_class::Function
    end
  end

  describe "#as_json" do
    it "returns the hash as json" do
      js_option = described_class.new(hoge: "fuga", piyo: "moge", moge: "piyo")
      js_option.add_function(name: "testFunction", body: function_body, args: function_args)

      expect(js_option.as_json).to be_a(Hash)
      expect(js_option.as_json).to eq("hoge" => "fuga", "piyo" => "moge", "moge" => "piyo", "testFunction" => js_option.as_json["testFunction"])
    end
  end

  describe "#to_s" do
    it "returns the hash as javascript object string" do
      js_option = described_class.new(hoge: "fuga", piyo: "moge", moge: "piyo")
      js_option.add_function(name: "testFunction", body: function_body, args: function_args)

      expect(js_option.to_s).to include '{"hoge":"fuga","piyo":"moge","moge":"piyo","testFunction":function(arg1, arg2) {;console.log(\\"Hello, \\\nWorld!\\");return true;}}' # rubocop:disable Layout/LineLength
    end
  end
end
