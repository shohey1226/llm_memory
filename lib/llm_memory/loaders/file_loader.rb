require 'find'
require_relative '../loader'

module LlmMemory
  class FileLoader
    include Loader

    register_loader :file

    def load(directory_path)
      files_array = []

      puts directory_path
      Find.find(directory_path) do |file_path|
        next if File.directory?(file_path)
    
        file_name = File.basename(file_path)
        file_content = File.read(file_path)
    
        files_array << {
          content: file_content,
          metadata: {
            file_name: file_name
          }
        }
      end
    
      files_array
    end    

  end
end