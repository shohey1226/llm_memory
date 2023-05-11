# frozen_string_literal: true

require_relative "lib/llm_memory/version"

Gem::Specification.new do |spec|
  spec.name = "llm_memory"
  spec.version = LlmMemory::VERSION
  spec.authors = ["Shohei Kameda"]
  spec.email = ["shoheik@cpan.org"]

  spec.summary = "A Ruby Gem for LLMs like ChatGPT to have memory using in-context learning"
  spec.description = "LLM Memory is a Ruby gem designed to provide large language models (LLMs) like ChatGPT with memory using in-context learning. This enables better integration with systems such as Rails and web services while providing a more user-friendly and abstract interface based on brain terms."
  spec.homepage = "https://github.com/shohey1226/llm_memory"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/shohey1226/llm_memory"
  spec.metadata["changelog_uri"] = "https://github.com/shohey1226/llm_memory/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency "tokenizers", "~> 0.3.3"
  spec.add_dependency "ruby-openai", "~> 3.7.0"
  spec.add_dependency "redis", "~> 4.6.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
