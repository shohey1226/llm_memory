require_relative "store"
require_relative "stores/redis_store"

require_relative "embedding"
require_relative "embeddings/openai"

module LlmMemory
  class Hippocampus

    def initialize(embedding_name: :openai, store_name: :redis)
      embedding_class = EmbeddingManager.embeddings[embedding_name]
      raise "Embedding '#{embedding_name}' not found." unless embedding_class
      @embedding_instance = embedding_class.new

      store_class = StoreManager.stores[store_name]
      raise "Store '#{store_name}' not found." unless store_class
      @store_instance = store_class.new      
    end

    def memorize(docs: [])
      # embed documents and add vector
      docs.each do |doc|
        content = doc[:content]
        vector = @embedding_instance.embed_document(content)
        docs[:vector] = vector
      end

      
      
    end

  end
end
