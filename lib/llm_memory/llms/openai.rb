require "openai"
require "llm_memory"

module LlmMemory
  module Llms
    module Openai
      def client
        @client ||= OpenAI::Client.new(
          access_token: LlmMemory.configuration.openai_access_token
        )
      end
    end
  end
end
