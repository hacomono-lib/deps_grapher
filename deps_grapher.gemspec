# frozen_string_literal: true

require_relative "lib/deps_grapher/version"

Gem::Specification.new do |spec|
  spec.name = "deps_grapher"
  spec.version = DepsGrapher::VERSION
  spec.authors = ["jk-es335"]
  spec.email = ["dev@hacomono.co.jp", "soultraingang.dev@gmail.com"]

  spec.summary = "Tool to visualize Ruby class dependencies"
  spec.homepage = "https://github.com/hacomono-lib/deps_grapher"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7"
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/hacomono-lib/deps_grapher"
  spec.metadata["changelog_uri"] = "https://github.com/hacomono-lib/deps_grapher"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features|docs)/|\.(?:git|travis|circleci|rspec|rubocop)|appveyor)})
    end
  end
  spec.bindir = "bin"
  spec.executables << "deps_grapher"
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport"
  spec.add_dependency "parser"
  spec.add_dependency "prism"
end
