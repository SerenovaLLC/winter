require 'winter/constants'
require 'winter/logger'

module Winter
  class Service

    def list
      list = []
      key_file = 'Winterfile'
      services_dir = File.join(WINTERFELL_DIR, "**", "**", key_file)
      Dir.glob(services_dir).each do |dir|
        #the + and -2 here is to eliminate the delimiters on either side of the 
        # service name
        s_start = File.join(WINTERFELL_DIR).length + 1
        s_end = dir.length-key_file.length - 2
        service_name = dir[s_start..s_end]
        if service_name.length > 0 
          list.push(service_name)
        end
      end
      return list
    end

  end
end
