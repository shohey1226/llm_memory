# frozen_string_literal: true

# loader
require_relative "llm_memory/loader"
require_relative "llm_memory/loaders/file"

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
    reader_class = LoaderManager.loaders[loader_name]
    raise "Loader '#{loader_name}' not found." unless loader_class
    loader_instance = loader_class.new
    loader_instance.load(*args)
  end



end
