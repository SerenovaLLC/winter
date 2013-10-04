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

require 'fileutils'

module Winter
  class Service
    TMP_FILENAME = 'winterfile.jar'

    def fetch( url )

      begin
        uri = URI.parse(url)
        file = uri.path.split('/').last

        content = Net::HTTP.get uri
        File.open(TMP_FILENAME, 'w') do |file|
          file.write content
        end
      rescue Exception=>e
        $LOG.error "Could not fetch winter configuration from : #{url}"
        $LOG.debug e
      end

      begin
        system "jar -xf #{TMP_FILENAME}"
      rescue Exception=>e
        $LOG.error "#{TMP_FILENAME} is corrupt or invalid."
        $LOG.debug e
      end
      
      cleanup
    end

    def cleanup
      File.delete(TMP_FILENAME) if File.exists?(TMP_FILENAME)
    end

    private :cleanup
  end
end
