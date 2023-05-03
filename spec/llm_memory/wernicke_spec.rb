require "spec_helper"
require "llm_memory/wernicke"

RSpec.describe LlmMemory::Wernicke do
  describe "file loder" do
    it "should returns docs" do
      directory_path = "path/to/your/directory"
      file_path1 = "path/to/your/directory/file1.txt"
      file_path2 = "path/to/your/directory/file2.txt"

      file_content1 = "This is file1 content."
      file_content2 = "This is file2 content."

      # Stub Find.find and File.directory? methods
      allow(Find).to receive(:find).with(directory_path).and_yield(file_path1).and_yield(file_path2)
      allow(File).to receive(:directory?).and_return(false)

      # Stub File.read method
      allow(File).to receive(:read).with(file_path1).and_return(file_content1)
      allow(File).to receive(:read).with(file_path2).and_return(file_content2)

      docs = LlmMemory::Wernicke.load(:file, directory_path)
      expect(docs).to eq([{content: "This is file1 content.", metadata: {file_name: "file1.txt"}}, {content: "This is file2 content.", metadata: {file_name: "file2.txt"}}])
    end
  end
end
