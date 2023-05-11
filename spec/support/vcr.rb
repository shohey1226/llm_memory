require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!

  config.default_cassette_options = {
    record: ENV.fetch("OPENAI_ACCESS_TOKEN", nil) ? :all : :new_episodes
  }

  config.filter_sensitive_data("<OPENAI_ACCESS_TOKEN>") { ENV["OPENAI_ACCESS_TOKEN"] }
  config.filter_sensitive_data("<OPENAI_ORGANIZATION_ID>") { ENV["OPENAI_ORGANIZATION_ID"] }

  # config.debug_logger = $stdout

  config.ignore_request do |request|
    request.uri == "https://huggingface.co/gpt2/resolve/main/tokenizer.json"
  end

  # Optionally, you can filter sensitive data, such as API keys, from the recorded cassettes.
  # config.filter_sensitive_data('<API_KEY>') { ENV['API_KEY'] }
end
