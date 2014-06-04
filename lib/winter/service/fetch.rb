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
require 'winter/dependency'

require 'fileutils'

module Winter
  class Service

    def fetch_url( url )

      begin
        uri = URI.parse(url)
        file = uri.path.split('/').last

        content = Net::HTTP.get uri
        File.open(file, 'w') do |file|
          file.write content
        end
      rescue Exception=>e
        $LOG.error "Could not fetch winter configuration from : #{url}"
        $LOG.debug e
        exit(-1)
      end

      extract_jar file
    end
    
    def fetch_GAV(group, artifact, version, repos=[])
      dep = Dependency.new
      dep.artifact      = artifact
      dep.group         = group
      dep.version       = version
      dep.repositories  = repos
      #dep.package       = options[:package] || 'jar'
      #dep.offline       = @options['offline'] || @options['offline'] == 'true'
      dep.transative    = true
      dep.destination   = File.join('.')

      dep.get or raise "Failed to fetch jar." 

      extract_jar "#{artifact}-#{version}.jar"
    end

    def extract_jar( file )
      begin
        system "jar -xf #{file}"
      rescue Exception=>e
        $LOG.error "#{file} is corrupt or invalid."
        $LOG.debug e
        exit(-1)
      end
      
      cleanup file
    end

    def cleanup(file)
      File.delete(file) if File.exists?(file)
    end

    private :cleanup, :extract_jar
  end

end
