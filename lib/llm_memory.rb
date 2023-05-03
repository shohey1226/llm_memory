# frozen_string_literal: true

# config
require_relative "llm_memory/configuration"

require_relative "llm_memory/hippocampus"
require_relative "llm_memory/broca"
require_relative "llm_memory/wernicke"

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
end
