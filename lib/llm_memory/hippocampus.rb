require_relative "store"
require_relative "stores/redis_store"

require_relative "embedding"
require_relative "embeddings/openai"

module LlmMemory
  class Hippocampus
    def initialize(embedding_name: :openai, store_name: :redis, chunk_size: 1024, chunk_overlap: 50)
      embedding_class = EmbeddingManager.embeddings[embedding_name]
      raise "Embedding '#{embedding_name}' not found." unless embedding_class
      @embedding_instance = embedding_class.new

      store_class = StoreManager.stores[store_name]
      raise "Store '#{store_name}' not found." unless store_class
      @store_instance = store_class.new

      # word count, not char count
      @chunk_size = chunk_size
      @chunk_overlap = chunk_overlap
    end

    def memorize(docs: [])
      docs = make_chunks(docs)
      docs = add_vectors(docs)
    end

    def add_vectors(docs)
      # embed documents and add vector
      result = []
      docs.each do |doc|
        content = doc[:content]
        metadata = doc[:metadata]
        vector = @embedding_instance.embed_document(content)
        result.push({
          content: content,
          metadata: metadata,
          vector: vector
        })
      end
      result
    end

    def make_chunks(docs)
      result = []
      docs.each do |item|
        content = item[:content]
        metadata = item[:metadata]
        words = content.split

        if words.length > @chunk_size
          start_index = 0

          while start_index < words.length
            end_index = [start_index + @chunk_size, words.length].min
            chunk_words = words[start_index...end_index]
            chunk = chunk_words.join(" ")
            result << {content: chunk, metadata: metadata}

            start_index += @chunk_size - @chunk_overlap # Move index to create a overlap
          end
        else
          result << {content: content, metadata: metadata}
        end
      end
      result
    end
  end
end
