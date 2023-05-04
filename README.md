# 🧠 LLM Memory 🌊🐴

LLM Memory is a Ruby gem designed to provide large language models (LLMs) like ChatGPT with memory using in-context learning.
This enables better integration with systems such as Rails and web services while providing a more user-friendly and abstract interface based on brain terms.

## Key Features

- In-context learning through input prompt context insertion
- Data connectors for various data sources
- Inspired by the Python library, [LlamaIndex](https://github.com/jerryjliu/llama_index)
- Focus on integration with existing systems
- Easy-to-understand abstraction using brain-related terms
- Plugin architecture for custom loader creation and extending LLM support

## LLM Memory Components

![image](https://user-images.githubusercontent.com/1880965/236099477-421b2003-79d2-4a7c-8f80-1afac4fd616d.png)


1. LlmMemory::Wernicke: Responsible for loading external data (currently from files). More loader types are planned for future development.

> Wernicke's area in brain is involved in the comprehension of written and spoken language

2. LlmMemory::Hippocampus: Handles interaction with vector databases to retrieve relevant information based on the query. Currently, Redis with the Redisearch module is used as the vector database. (Note that Redisearch is a proprietary modules and available on RedisCloud, which offers a free plan). The reason for choosing this is that Redis is commonly used and easy to integrate with web services.

> Hippocampus in brain plays important roles in the consolidation of information from short-term memory to long-term memory

3. LlmMemory::Broca: Responds to queries using memories provided by the Hippocampus component. ERB is used for prompt templates, and a variety of templates can be found online (e.g., in [LangChain Hub](https://github.com/hwchase17/langchain-hub#-prompts)).

> Broca's area in brain is also known as the motor speech area.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add llm_memory

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install llm_memory

### Setup

Set environment variable `OPENAI_ACCESS_TOKEN` and `REDISCLOUD_URL`
or set in initializer.

```ruby
LlmMemory.configure do |c|
  c.openai_access_token = "xxxxx"
  c.redis_url = "redis://xxxx:6379"
end
```

## Usage

To use LLM Memory, follow these steps:

1. Install the gem: gem install llm_memory
2. Set up Redis with Redisearch module enabled - Go to [Reids Cloud](https://redis.com/redis-enterprise-cloud/overview/) and get the redis url
3. Configure LLM Memory to connect to your Redis instance
4. Use LlmMemory::Wernicke to load data from your external sources
5. Use LlmMemory::Hippocampus to search for relevant information based on user queries
6. Create and use ERB templates with LlmMemory::Broca to generate responses based on the information retrieved

```ruby
docs = LlmMemory::Wernicke.load(:file, "/tmp/a_directory")
# docs is just an array of hash.
# You don't have to use load method but
# create own hash with having content and metadata(optional)
# docs = [{
#   content: "Hi there",
#   metadata: {
#     file_name: "a.txt"
#   }
# },,,]

hippocampus = LlmMemory::Hippocampus.new
hippocampus.memorize(docs)

query_str = "What is my name?"
related_docs = hippocampus.query(query_str, limit: 3)
#[{
#   vector_score: "0.192698478699",
#   content: "My name is Mike",
#   metadata: { ... }
#},,,]

# ERB
template = <<-TEMPLATE
Context information is below.
---------------------
<% related_docs.each do |doc| %>
<%= doc[:content] %>
file: <%= doc[:metadata][:file_name] %>

<% end %>
---------------------
Given the context information and not prior knowledge,
answer the question: <%= query_str %>
TEMPLATE

broca = LlmMemory::Broca.new(prompt: tempate, model: 'gpt-3.5-turbo')
messages = broca.respond(query_str: query_str, related_docs: related_docs)

...
query_str2 = "How are you?"
related_docs = hippocampus.query(query_str2, limit: 3)
message2 = broca.respond(query_str: query_str2, related_docs: related_docs)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/llm_memory. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/llm_memory/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the LlmMemory project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/llm_memory/blob/master/CODE_OF_CONDUCT.md).
