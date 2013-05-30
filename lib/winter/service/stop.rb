require 'winter/constants'
require 'winter/logger'

module Winter
  class Service

    # stop winterfell service
    def stop(service)
      f_pid = File.join(WINTERFELL_DIR,RUN_DIR,service, "pid")
      #service_dir = File.join(File.split(winterfile)[0],RUN_DIR,@config['service'])
      if File.exists?(f_pid)
        pid_file = File.open(f_pid, "r")
        pid = pid_file.read().to_i
        Process.kill("TERM", -Process.getpgid(pid))
        File.delete(f_pid)
      else
        $LOG.error("Failed to find process Id file: #{f_pid}")
        exit
      end
    end

  end
end
