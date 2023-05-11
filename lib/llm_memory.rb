# frozen_string_literal: true

require "logger"
# config
require_relative "llm_memory/configuration"
require_relative "llm_memory/hippocampus"
require_relative "llm_memory/broca"
require_relative "llm_memory/wernicke"
require_relative "llm_memory/version"

module LlmMemory
  class Error < StandardError; end

  class << self
    attr_accessor :configuration, :log_level

    def logger
      @logger ||= Logger.new($stdout).tap do |logger|
        logger.level = log_level || Logger::INFO
      end
    end
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration) if block_given?
  end
end
