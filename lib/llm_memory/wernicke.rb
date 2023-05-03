# loader
require_relative "loader"
require_relative "loaders/file_loader"

module LlmMemory
  class Wernicke
    def self.load(loader_name, *args)
      loader_class = LoaderManager.loaders[loader_name]
      raise "Loader '#{loader_name}' not found." unless loader_class
      loader_instance = loader_class.new
      loader_instance.load(*args)
    end
  end
end
