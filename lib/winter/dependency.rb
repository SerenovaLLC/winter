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

require 'winter/logger'

module Winter

  class Dependency
    attr_accessor :artifact
    attr_accessor :group
    attr_accessor :version
    attr_accessor :repositories
    attr_accessor :package
    attr_accessor :offline
    attr_accessor :transative
    attr_accessor :destination

    def initialize
      @artifact     = nil
      @group        = nil
      @version      = 'LATEST'
      @repositories = []
      @package      = 'jar'
      @offline      = false
      @transative   = false
      @verbose      = false 
      @destination  = '.'
    end

    def getMaven
      dest_file = File.join(@destination,outputFilename)

      c =  "mvn org.apache.maven.plugins:maven-dependency-plugin:2.5:get " 
      c << " -DremoteRepositories=#{@repositories.join(',').shellescape}" 
      c << " -Dtransitive=#{@transative}" 
      c << " -Dartifact=#{@group.shellescape}:#{@artifact.shellescape}:#{@version.shellescape}:#{@package.shellescape}" 
      c << " -Ddest=#{dest_file.shellescape}"

      if @offline
        c << " --offline"
      end

      if !@verbose
        #quiet mode is default
        c << " -q"
      end

      $LOG.debug c
      result = system( c )
      if result == false
        $LOG.error("Failed to retrieve artifact: #{@group}:#{@artifact}:#{@version}:#{@package}")
      else
        $LOG.info "#{@group}:#{@artifact}:#{@version}:#{@package}"
        $LOG.debug dest_file
      end
      return result
    end

    def outputFilename
      "#{@artifact}-#{@version}.#{@package}"
    end
  end

end

