require 'winter/constants'
require 'winter/logger'

module Winter
  class Service

    def status
      pid_files = Dir.glob(File.join(WINTERFELL_DIR,RUN_DIR, "**", "pid"))
      if( pid_files.length == 0 )
        $LOG.info "No services are running."
      end

      services = {}
      
      pid_files.each do |f_pid|
        service = f_pid.sub( %r{#{WINTERFELL_DIR}/#{RUN_DIR}/([^/]+)/pid}, '\1')
        pid_file = File.open(f_pid, "r")
        pid = pid_file.read().to_i
      
        begin
          Process.getpgid( pid )
          running = "Running"
        rescue Errno::ESRCH
          running = "Dangling pid file : #{f_pid}"
        end

        services["#{service} (#{pid})"] = "#{running}"
      end

      return services
    end

  end
end
