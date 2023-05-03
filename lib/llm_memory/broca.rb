require "erb"

module LlmMemory
  class Broca
    include Llms::Openai

    def initialize(prompt:, model: "gpt-3.5-turbo", temperature: 0.7)
      @prompt = prompt
      @model = model
      @messages = []
      @temperature = temperature
    end

    def respond(*args)
      final_prompt = generate_prompt(*args)
      @messages.push({role: "user", content: final_prompt})
      response = client.chat(
        parameters: {
          model: @model,
          messages: @messages,
          temperature: @temperature
        }
      )
      response_conent = response.dig("choices", 0, "message", "content")
      @messages.push({role: "system", content: response_conent})
      response_conent
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
