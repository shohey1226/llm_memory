require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!

  config.default_cassette_options = {
    record: ENV.fetch("OPENAI_ACCESS_TOKEN", nil) ? :all : :new_episodes
  }
  config.filter_sensitive_data("<OPENAI_ACCESS_TOKEN>") { OpenAI.configuration.access_token }
  config.filter_sensitive_data("<OPENAI_ORGANIZATION_ID>") { OpenAI.configuration.organization_id }

  # Optionally, you can filter sensitive data, such as API keys, from the recorded cassettes.
  # config.filter_sensitive_data('<API_KEY>') { ENV['API_KEY'] }
end
