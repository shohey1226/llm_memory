module LlmMemory
  class Configuration
    attr_accessor :openai_access_token, :openai_organization_id, :redis_url

    def initialize
      @openai_access_token = ENV["OPENAI_ACCESS_TOKEN"]
      @openai_organization_id = nil
      @redis_url = ENV["REDISCLOUD_URL"] || "redis://localhost:6379"
    end
  end
end
