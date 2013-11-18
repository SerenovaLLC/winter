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
        pid = nil;
        File.open(f_pid, "r") do |f|
          pid = f.read().to_i
        end

        begin
          pgid = Process.getpgid pid
          pgid *= -1 if !config['daemonize']
          Process.kill("TERM", pgid)
        rescue => e
          $LOG.debug( e )
          $LOG.info( "Process #{pid} does not exist. Removing pid file." )
        end

        begin
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
