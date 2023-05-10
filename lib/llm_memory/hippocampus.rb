require_relative "store"
require_relative "stores/redis_store"

require_relative "embedding"
require_relative "embeddings/openai"

module LlmMemory
  class Hippocampus
    def initialize(
      embedding_name: :openai,
      chunk_size: 1024,
      chunk_overlap: 50,
      store_name: :redis,
      index_name: "llm_memory"
    )
      LlmMemory.configure

      embedding_class = EmbeddingManager.embeddings[embedding_name]
      raise "Embedding '#{embedding_name}' not found." unless embedding_class
      @embedding_instance = embedding_class.new

      store_class = StoreManager.stores[store_name]
      raise "Store '#{store_name}' not found." unless store_class
      @store = store_class.new(index_name: index_name)

      # char count, not word count
      @chunk_size = chunk_size
      @chunk_overlap = chunk_overlap
    end

    # validate the document format
    def validate_documents(documents)
      is_valid = documents.all? do |hash|
        hash.is_a?(Hash) &&
          hash.key?(:content) && hash[:content].is_a?(String) &&
          hash.key?(:metadata) && hash[:metadata].is_a?(Hash)
      end
      unless is_valid
        raise "Your documents need to have an array of hashes (content: string and metadata: hash)"
      end
    end

    def memorize(docs)
      validate_documents(docs)
      docs = make_chunks(docs)
      docs = add_vectors(docs)
      @store.create_index unless @store.index_exists?
      @store.add(data: docs)
    end

    def query(query_str, limit: 3)
      vector = @embedding_instance.embed_document(query_str)
      response_list = @store.search(query: vector, k: limit)
      response_list.shift # the first one is the size
      # now [redis_key1, [],,, ]
      result = response_list.each_slice(2).to_h.values.map { |v|
        v.each_slice(2).to_h.transform_keys(&:to_sym)
      }
      result.each do |item|
        item[:metadata] = JSON.parse(item[:metadata])
      end
      result
    end

    def forgot_all
      @store.drop_index
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
        if content.length > @chunk_size
          start_index = 0
          while start_index < content.length
            end_index = [start_index + @chunk_size, content.length].min
            chunk = content[start_index...end_index]
            result << {content: chunk, metadata: metadata}
            break if end_index == content.length
            start_index += @chunk_size - @chunk_overlap
          end
        else
          result << {content: content, metadata: metadata}
        end
      end
      result
    end
  end
end
