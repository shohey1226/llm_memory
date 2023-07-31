require "redis"
require_relative "../store"
require "json"

module LlmMemory
  class RedisStore
    include Store

    register_store :redis

    def initialize(
      index_name: "llm_memory",
      content_key: "content",
      vector_key: "vector",
      metadata_key: "metadata"
    )
      @index_name = index_name
      @content_key = content_key
      @vector_key = vector_key
      @metadata_key = metadata_key
      @client = Redis.new(url: LlmMemory.configuration.redis_url)
    end

    def info
      @client.call(["INFO"])
    end

    def load_data(file_path)
      CSV.read(file_path)
    end

    def list_indexes
      @client.call("FT._LIST")
    end

    def index_exists?
      begin
        @client.call(["FT.INFO", @index_name])
      rescue
        return false
      end
      true
    end

    def drop_index
      # DD deletes all document hashes
      @client.call(["FT.DROPINDEX", @index_name, "DD"])
    end

    # dimention: 1536 for ada-002
    def create_index(dim: 1536, distance_metric: "COSINE")
      # LangChain index
      # schema = (
      #   TextField(name=content_key),
      #   TextField(name=metadata_key),
      #   VectorField(
      #       vector_key,
      #       "FLAT",
      #       {
      #           "TYPE": "FLOAT32",
      #           "DIM": dim,
      #           "DISTANCE_METRIC": distance_metric,
      #       },
      #   ),
      # )
      command = [
        "FT.CREATE", @index_name, "ON", "HASH",
        "PREFIX", "1", "#{@index_name}:",
        "SCHEMA",
        @content_key, "TEXT",
        @metadata_key, "TEXT",
        @vector_key, "VECTOR", "FLAT", 6, "TYPE", "FLOAT32", "DIM", dim, "DISTANCE_METRIC", distance_metric
      ]
      @client.call(command)
    end

    # data = [{ content: "", content_vector: [], metadata: {} }]
    def add(data: [])
      result = {}
      @client.pipelined do |pipeline|
        data.each_with_index do |d, i|
          key = @index_name # index_name:create_time:metadata_timestamp:uuid
          timestamp = d.dig(:metadata, :timestamp)
          key += ":#{Time.now.strftime("%Y%m%d%H%M%S")}"
          key += ":#{timestamp}"
          key += ":#{SecureRandom.hex(8)}"

          meta_json = d[:metadata].nil? ? "" : d[:metadata].to_json # serialize
          vector_value = d[:vector].map(&:to_f).pack("f*")
          pipeline.hset(
            key,
            {
              @content_key => d[:content],
              @vector_key => vector_value,
              @metadata_key => meta_json
            }
          )
          result[key] = d[:content]
        end
      end
      result
    # data.each_with_index do |d, i|
    #   key = "#{@index_name}:#{i}"
    #   vector_value = d[:content_vector].map(&:to_f).pack("f*")
    #   pp vector_value
    #   @client.hset(
    #     key,
    #     {
    #       @content_key => d[:content],
    #       @vector_key => vector_value,
    #       @metadata_key => ""
    #     }
    #   )
    # end
    # rescue Redis::Pipeline::Error => e
    #   # Handle the error if there is any issue with the pipeline execution
    #   puts "Pipeline Error: #{e.message}"
    # rescue Redis::BaseConnectionError => e
    #   # Handle connection errors
    #   puts "Connection Error: #{e.message}"
    rescue => e
      # Handle any other errors
      puts "Unexpected Error: #{e.message}"
    end

    def delete(key)
      @client.del(key) if @client.exists?(key)
    end

    def delete_all
      list.keys.each do |key|
        delete(key)
      end
    end

    def list(patterns = [])
      patterns = if patterns.empty?
        ["#{@index_name}:*"]
      else
        patterns.map { |pattern| "#{@index_name}:#{pattern}" }
      end
      data = {}
      patterns.each do |pattern|
        @client.keys(pattern).each do |key|
          obj = @client.hgetall(key)
          data[key] = {
            content: obj.dig("content"),
            metadata: JSON.parse(obj.dig("metadata"))
          }
        end
      end
      data
    end

    def update
    end

    def search(query: [], k: 3)
      packed_query = query.map(&:to_f).pack("f*")
      command = [
        "FT.SEARCH",
        @index_name,
        "*=>[KNN #{k} @vector $blob AS vector_score]",
        "PARAMS",
        2,
        "blob",
        packed_query,
        "SORTBY",
        "vector_score",
        "ASC",
        "LIMIT",
        0,
        k,
        "RETURN",
        3,
        "vector_score",
        @content_key,
        @metadata_key,
        "DIALECT",
        2
      ]
      response_list = @client.call(command)
      response_list.shift # the first one is the size
      # now [redis_key1, [],,, ]
      result = response_list.each_slice(2).to_h.values.map { |v|
        v.each_slice(2).to_h.transform_keys(&:to_sym)
      }
      result.each do |item|
        hash = JSON.parse(item[:metadata])
        item[:metadata] = hash.transform_keys(&:to_sym)
      end
      result
    end
  end
end
