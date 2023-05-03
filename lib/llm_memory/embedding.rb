# lib/lilyama_index/Embedding.rb
module LlmMemory
  module Embedding
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def register_embedding(name)
        LlmMemory::EmbeddingManager.register_embedding(name, self)
      end
    end

    def embed_document(text)
      raise NotImplementedError, "Each Embedding must implement the 'embed_document' method."
    end
  end

  class EmbeddingManager
    @embeddings = {}

    def self.register_embedding(name, klass)
      @embeddings[name] = klass
    end

    def self.embeddings
      @embeddings
    end
  end
end
