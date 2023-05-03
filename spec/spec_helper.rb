# frozen_string_literal: true

require "support/vcr"
require "llm_memory"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  if ENV.fetch("OPENAI_ACCESS_TOKEN", nil)
    warning = "WARNING! Specs are hitting the OpenAI API using your OPENAI_ACCESS_TOKEN! This
costs at least 2 cents per run and is very slow! If you don't want this, unset
OPENAI_ACCESS_TOKEN to just run against the stored VCR responses."
    warning = RSpec::Core::Formatters::ConsoleCodes.wrap(warning, :bold_red)

    config.before(:suite) { RSpec.configuration.reporter.message(warning) }
    config.after(:suite) { RSpec.configuration.reporter.message(warning) }
  end

  config.before(:all) do
    LlmMemory.configure do |c|
      c.openai_access_token = ENV.fetch("OPENAI_ACCESS_TOKEN", "dummy-token")
      c.redis_url = ENV.fetch("REDISCLOUD_URL", "redis://localhost:6379")
    end
  end
end
