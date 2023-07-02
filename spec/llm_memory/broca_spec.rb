require "spec_helper"
require "llm_memory/broca"

RSpec.describe LlmMemory::Broca do
  template = <<~TEMPLATE
    Context information is below.
    ---------------------
    <% related_docs.each do |doc| %>
    <%= doc[:content] %>
    
    <% end %>
    ---------------------
    Given the context information and not prior knowledge,
    answer the question: <%= query_str %>
  TEMPLATE

  describe "new" do
    it "instantiates a new Broca object" do
      broca = LlmMemory::Broca.new(prompt: "erb_template")
      expect(broca).to be_a(LlmMemory::Broca)
    end
  end

  describe "generate_prompt" do
    it "creates prompt with erb" do
      related_docs = [{content: "foo"}, {content: "bar"}]
      broca = LlmMemory::Broca.new(prompt: template)
      prompt = broca.generate_prompt(related_docs: related_docs, query_str: "how are you?")
      expect(prompt).to include("foo")
      expect(prompt).to include("how are you?")
    end
  end

  describe "adjust_token_count" do
    it "should count token", :vcr do
      broca = LlmMemory::Broca.new(prompt: "I", max_token: 4)
      broca.messages = [{content: "foo bar"}, {content: "this is my pen"}]
      broca.adjust_token_count
      expect(broca.messages).to eq([{content: "this is my pen"}])
    end
  end

  describe "generate_prompt" do
    it "runs respond method", :vcr do
      related_docs = [{content: "My name is Shohei"}, {content: "I'm a software engineer"}]
      broca = LlmMemory::Broca.new(prompt: template)
      res = broca.respond(related_docs: related_docs, query_str: "what is my name?")
      expect(res).to include("Shohei")
    end

    it "runs respond_with_schema method", :vcr do
      related_docs = [{content: "My name is Shohei"}, {content: "I'm a software engineer"}]
      broca = LlmMemory::Broca.new(prompt: template)
      res = broca.respond_with_schema(
        context: {related_docs: related_docs, query_str: "what is my name?"},
        schema: {
          type: :object,
          properties: {
            name: {
              type: :string,
              description: "The name of person"
            }
          },
          required: ["name"]
        }
      )
      expect(res).to include({name: "Shohei"})
    end
  end
end
