# lib/lilyama_index/loader.rb
module LlmMemory
  module Loader
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def register_loader(name)
        LlmMemory::LoaderManager.register_loader(name, self)
      end
    end

    def load
      raise NotImplementedError, "Each loader must implement the 'load' method."
    end
  end

  class LoaderManager
    @loaders = {}

    def self.register_loader(name, klass)
      @loaders[name] = klass
    end

    def self.loaders
      @loaders
    end
  end
end
