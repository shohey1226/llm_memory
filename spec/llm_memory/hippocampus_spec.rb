require "spec_helper"
require "llm_memory/hippocampus"

RSpec.describe LlmMemory::Hippocampus do
  it "instantiates a new Broca object" do
    hippocampus = LlmMemory::Hippocampus.new
    expect(hippocampus).to be_a(LlmMemory::Hippocampus)
  end

  describe "make_chunks" do
    it "should returns docs" do
      hippocampus = LlmMemory::Hippocampus.new(chunk_size: 1, chunk_overlap: 0)
      docs = [{content: "foo bar", metadata: {info: "test"}}]
      docs = hippocampus.make_chunks(docs)
      expect(docs).to eq([{content: "foo", metadata: {info: "test"}}, {content: "bar", metadata: {info: "test"}}])
    end
  end
end
