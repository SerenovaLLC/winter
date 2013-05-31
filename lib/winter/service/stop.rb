require 'winter/constants'
require 'winter/logger'

module Winter
  class Service

    # stop winterfell service
    def stop(winterfile='Winterfile', options={})
      tmp = DSL.evaluate winterfile, options
      config = tmp[:config]
      service = config['service']

      @service_dir = File.join(File.split(winterfile)[0],RUN_DIR,service)
      f_pid = File.join(@service_dir, "pid")

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
