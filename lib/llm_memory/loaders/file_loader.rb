require "find"
require_relative "../loader"

module LlmMemory
  class FileLoader
    include Loader

    register_loader :file

    def load(directory_path)
      files_array = []
      Find.find(directory_path) do |file_path|
        next if File.directory?(file_path)

        file_name = File.basename(file_path)
        file_content = File.read(file_path)
        ctime = File.ctime(file_path)

        files_array << {
          content: file_content,
          metadata: {
            file_name: file_name,
            timestamp: ctime.strftime("%Y%m%d%H%M%S") # YYMMDDHHmmss
          }
        }
      end

      files_array
    end
  end
end
