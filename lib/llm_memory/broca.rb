require "erb"
require "tiktoken_ruby"

module LlmMemory
  class Broca
    include Llms::Openai
    attr_accessor :messages

    def initialize(
      prompt:,
      model: "gpt-3.5-turbo",
      temperature: 0.7,
      max_token: 4096
    )
      LlmMemory.configure
      @prompt = prompt
      @model = model
      @messages = []
      @temperature = temperature
      @max_token = max_token
    end

    def respond(*args)
      final_prompt = generate_prompt(*args)
      @messages.push({role: "user", content: final_prompt})
      adjust_token_count
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

    def adjust_token_count
      count = 0
      new_messages = []
      @messages.reverse_each do |message|
        encoded = tokenizer.encode(message[:content])
        if count < @max_token
          count += encoded.length
          new_messages.push(message)
        else
          break
        end
      end
      @messages = new_messages.reverse
    end

    def tokenizer
      @tokenizer ||= Tiktoken.encoding_for_model("gpt-4")
    end
  end
end
