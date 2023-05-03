require_relative "llms/openai"
require "erb"

module LlmMemory
  class Broca
    def initialize(prompt:, model: "gpt-3.5-turbo")
      @prompt = prompt
      @model = model
      @messages = []
    end

    def respond(*args)
      final_prompt = generate_prompt(*args)
      pp final_prompt
    end

    def generate_prompt(*args)
      merged_args = args.reduce(:merge)
      erb = ERB.new(@prompt)
      erb.result_with_hash(merged_args)
    end

    def estimate_token_count
    end
  end
end
