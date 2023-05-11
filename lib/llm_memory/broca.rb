require "erb"
require "tokenizers"

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

    def respond(args)
      final_prompt = generate_prompt(args)
      @messages.push({role: "user", content: final_prompt})
      adjust_token_count
      begin
        response = client.chat(
          parameters: {
            model: @model,
            messages: @messages,
            temperature: @temperature
          }
        )
        response_content = response.dig("choices", 0, "message", "content")
        @messages.push({role: "system", content: response_content})
        response_content
      rescue => e
        puts e.inspect
        # @messages = []
        nil
      end
    end

    def generate_prompt(args)
      erb = ERB.new(@prompt)
      erb.result_with_hash(args)
    end

    def adjust_token_count
      count = 0
      new_messages = []
      @messages.reverse_each do |message|
        encoded = tokenizer.encode(message[:content], add_special_tokens: true)
        if count < @max_token
          count += encoded.tokens.length
          new_messages.push(message)
        else
          break
        end
      end
      @messages = new_messages.reverse
    end

    def tokenizer
      @tokenizer ||= Tokenizers.from_pretrained("gpt2")
    end
  end
end
