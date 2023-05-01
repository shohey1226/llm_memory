# frozen_string_literal: true

# config
require_relative "llm_memory/configuration"
# loader
require_relative "llm_memory/loader"
require_relative "llm_memory/loaders/file_loader"

# main role of memory
require_relative "llm_memory/hippocampus"

require_relative "llm_memory/version"

module LlmMemory
  class Error < StandardError; end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
  end
  configure # init for default values

  # Loader
  def self.load(loader_name, *args)
    loader_class = LoaderManager.loaders[loader_name]
    raise "Loader '#{loader_name}' not found." unless loader_class
    loader_instance = loader_class.new
    loader_instance.load(*args)
  end



end
