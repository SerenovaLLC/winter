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
require 'winter/service/status'

module Winter
  class Service

    def build(winterfile, options)
      #dsl = DSL.new options
      dsl = DSL.evaluate winterfile, options
      dependencies = dsl[:dependencies]
      service = dsl[:config]['service']
      service_dir = File.join(WINTERFELL_DIR,RUN_DIR,service)
      #$LOG.debug dependencies
      
      if options['clean'] and File.directory?(service_dir)
        s = Winter::Service.new
        stats = s.status
        if stats.size == 0
          FileUtils.rm_r dir
          $LOG.debug "Deleted service directory #{dir}"
        else
          stats.each do |srvs,status|
            $LOG.info "#{service} == #{srvs} && #{status}"
            if service == srvs && status !~ /running/i
              dir = File.join(WINTERFELL_DIR,RUN_DIR,service)
              FileUtils.rm_r dir
              $LOG.debug "Deleted service directory #{dir}"
            end
          end
        end
      end

      dependencies.each do |dep|
        dep.getMaven
      end
    end

  end
end
