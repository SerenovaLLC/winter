# Copyright 2013 LiveOps, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not 
# use this file except in compliance with the License.  You may obtain a copy 
# of the License at:
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT 
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the 
# License for the specific language governing permissions and limitations 
# under the License.

require 'winter/constants'
require 'winter/logger'

module Winter
  class Service

    # stop winterfell service
    def stop(winterfile='Winterfile', options={})
      begin
        tmp = DSL.evaluate winterfile, options
        config = tmp[:config]
        service = config['service']
      rescue Exception=>e
        $LOG.error e
        exit
      end

      @service_dir = File.join(File.split(winterfile)[0],RUN_DIR,service)
      f_pid = File.join(@service_dir, "pid")
      if File.exists?(f_pid)
        pid = nil
        pid_string = nil
        File.open(f_pid, "r") do |f|
          pid_string = f.read()
          pid = pid_string.to_i
        end

        #Send a TERM to the container if we have a non bogus pid
        if pid > 0 
          begin
            $LOG.info("Attempting to terminate #{pid}")
            Process.kill("TERM", pid)
          rescue => e
            $LOG.debug( e )
            $LOG.info("Unable to control process with pid #{pid}.")
            $LOG.info("Either your user has insufficent rights, or the process doesn't exist")
          end
          
          #Wait for things to stop. 
          begin 
            $LOG.info("Waiting for the process with pid #{pid} to stop")
            sleep 1 while Process.kill(0,pid)
          rescue => e
            $LOG.info("The container seems to have exited.")
          end
        else
          $LOG.info("An invalid pid value was found in the pid file. (\"#{pid_string}\" was parsed as #{pid})")
        end
        
        #If things worked (Or we couldn't find a pid)... then we're good to delete. 
        begin
          $LOG.info("Removing the pid file")
          File.unlink(f_pid)
        rescue
          $LOG.error( "Error deleting PID file." )
        end
      else
        $LOG.error("Failed to find process Id file: #{f_pid}")
        false
      end
      true
    end

  end
end
