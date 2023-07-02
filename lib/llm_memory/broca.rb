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
        LlmMemory.logger.debug(response)
        response_content = response.dig("choices", 0, "message", "content")
        @messages.push({role: "system", content: response_content}) unless response_content.nil?
        response_content
      rescue => e
        LlmMemory.logger.info(e.inspect)
        # @messages = []
        nil
      end
    end

    def respond_with_schema(context: {}, schema: {})
      response_content = respond(context)
      begin
        response = client.chat(
          parameters: {
            model: "gpt-3.5-turbo-0613", # as of July 3, 2023
            messages: [
              {
                role: "user",
                content: response_content
              }
            ],
            functions: [
              {
                name: "broca",
                description: "Formating the content with the specified schema",
                parameters: schema
              }
            ]
          }
        )
        LlmMemory.logger.debug(response)
        message = response.dig("choices", 0, "message")
        if message["role"] == "assistant" && message["function_call"]
          function_name = message.dig("function_call", "name")
          args =
            JSON.parse(
              message.dig("function_call", "arguments"),
              {symbolize_names: true}
            )
          if function_name == "broca"
            args
          end
        end
      rescue => e
        LlmMemory.logger.info(e.inspect)
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
        token_count = encoded.tokens.length
        count += token_count
        if count <= @max_token
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
