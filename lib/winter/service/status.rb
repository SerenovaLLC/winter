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
