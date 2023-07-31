require "spec_helper"
require "llm_memory/hippocampus"
require "llm_memory_pgvector"

RSpec.describe LlmMemory::Hippocampus do
  it "instantiates a new Broca object" do
    hippocampus = LlmMemory::Hippocampus.new
    expect(hippocampus).to be_a(LlmMemory::Hippocampus)
  end

  describe "make_chunks" do
    it "should returns the same docs if content length is less than chunk_size" do
      hippocampus = LlmMemory::Hippocampus.new
      docs = [{content: "foo bar", metadata: {info: "test"}}]
      docs = hippocampus.make_chunks(docs)
      expect(docs).to eq([{content: "foo bar", metadata: {info: "test"}}])
    end

    it "should returns chunked docs" do
      hippocampus = LlmMemory::Hippocampus.new(chunk_size: 4, chunk_overlap: 2)
      docs = [{content: "123456789", metadata: {info: "test"}}]
      docs = hippocampus.make_chunks(docs)
      expect(docs).to eq([
        {content: "1234", metadata: {info: "test"}},
        {content: "3456", metadata: {info: "test"}},
        {content: "5678", metadata: {info: "test"}},
        {content: "789", metadata: {info: "test"}}
      ])
    end

    it "should returns chunked docs" do
      hippocampus = LlmMemory::Hippocampus.new(chunk_size: 5, chunk_overlap: 3)
      docs = [{content: "123456789", metadata: {info: "test"}}]
      docs = hippocampus.make_chunks(docs)
      expect(docs).to eq([
        {content: "12345", metadata: {info: "test"}},
        {content: "34567", metadata: {info: "test"}},
        {content: "56789", metadata: {info: "test"}}
      ])
    end
  end

  describe "add_vectors", :vcr do
    it "should returns docs that has vector" do
      hippocampus = LlmMemory::Hippocampus.new(chunk_size: 1, chunk_overlap: 0)
      docs = [{content: "Hello, I'm Shohei. I'm working as a sotware developer", metadata: {info: "test"}}]
      docs = hippocampus.add_vectors(docs)
      doc = docs.first
      expect(doc[:vector].length).to eq(1536)
      expect(doc[:content]).to eq("Hello, I'm Shohei. I'm working as a sotware developer")
      expect(doc[:metadata]).to eq({info: "test"})
    end
  end

  describe "memorize", :vcr do
    it "should add docs to redis", :vcr do
      hippocampus = LlmMemory::Hippocampus.new
      timestamp = "20201231235959"
      docs = [
        {content: "Hello, I'm Shohei.", metadata: {info: "name", timestamp: timestamp}},
        {content: "I'm working as a sotware developer", metadata: {info: "profession", timestamp: timestamp}},
        {content: "I like music", metadata: {info: "hobby", timestamp: timestamp}}
      ]
      hippocampus.forget_all
      res = hippocampus.memorize(docs)
      expect(res.keys.map { |k| k.split(":")[2] }.uniq.first).to eq timestamp
      expect(hippocampus.list.keys.sort).to eq res.keys.sort
      expect(res.values.first).to eq("Hello, I'm Shohei.")
      hippocampus.forget(res.keys.first)
      expect(hippocampus.list.keys.size).to eq(2)
    end
  end

  describe "query", :vcr do
    it "search from redis and find", :vcr do
      hippocampus = LlmMemory::Hippocampus.new
      timestamp = "20201231235959"
      docs = [
        {content: "Hello, I'm Shohei.", metadata: {info: "name", timestamp: timestamp}},
        {content: "I'm working as a sotware developer", metadata: {info: "profession", timestamp: timestamp}},
        {content: "I like music", metadata: {info: "hobby", timestamp: timestamp}}
      ]
      hippocampus.forget_all
      hippocampus.memorize(docs)
      res = hippocampus.query("What is my name?", limit: 2)
      # pp res
      expect(res.length).to eq(2)
      expect(res.first[:content]).to eq("Hello, I'm Shohei.")
      expect(res.first[:metadata][:info]).to eq("name")
    end
  end

  describe "pgvector" do
    before do
      LlmMemoryPgvector.configure do |c|
        c.pg_url = "postgresql://postgres:foobar@localhost"
      end
    end

    it "search from vgvector and find", :vcr do
      hippocampus = LlmMemory::Hippocampus.new(store: :pgvector)
      hippocampus.forget_all
      docs = [
        {content: "Hello, I'm Shohei.", metadata: {info: "name"}},
        {content: "I'm working as a sotware developer", metadata: {info: "profession"}},
        {content: "I like music", metadata: {info: "hobby"}}
      ]
      hippocampus.memorize(docs)
      res = hippocampus.query("What is my name?", limit: 2)
      expect(res.first[:content]).to eq("Hello, I'm Shohei.")
      expect(res.first[:metadata][:info]).to eq("name")
    end
  end
end
