require_relative "../embedding"
require_relative "../llms/openai"

module LlmMemory
  module Embeddings
    class Openai
      include LlmMemory::Embedding
      include Llms::Openai

      register_embedding :openai

      def embed_documents(texts, model: "text-embedding-ada-002")
        embedding_list = []
        texts.each do |txt|
          res = client.embeddings(
            parameters: {
              model: model,
              input: txt
            }
          )
          embedding_list.push(res["data"][0]["embedding"])
        end
        embedding_list
      end

      def embed_document(text, model: "text-embedding-ada-002")
        res = client.embeddings(
          parameters: {
            model: model,
            input: text
          }
        )
        res["data"][0]["embedding"]
      end
    end
  end
end
