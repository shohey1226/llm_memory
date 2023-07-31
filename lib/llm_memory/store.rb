# lib/lilyama_index/store.rb
module LlmMemory
  module Store
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def register_store(name)
        LlmMemory::StoreManager.register_store(name, self)
      end
    end

    def create_index
      raise NotImplementedError, "Each store must implement the 'create_index' method."
    end

    def index_exists?
      raise NotImplementedError, "Each store must implement the 'index_exists?' method."
    end

    def drop_index
      raise NotImplementedError, "Each store must implement the 'drop_index' method."
    end

    def add
      raise NotImplementedError, "Each store must implement the 'add' method."
    end

    def list
      raise NotImplementedError, "Each store must implement the 'list' method."
    end

    def delete
      raise NotImplementedError, "Each store must implement the 'delete' method."
    end

    def search
      raise NotImplementedError, "Each store must implement the 'search' method."
    end
  end

  class StoreManager
    @stores = {}

    def self.register_store(name, klass)
      @stores[name] = klass
    end

    def self.stores
      @stores
    end
  end
end
