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
require 'fileutils'
require 'digest/md5'
require 'net/http'
require 'xmlsimple'

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
    
    def get    
      if ! File.directory?(@destination)  
        $LOG.debug "Create the destination folder if its not already there."
        FileUtils.mkdir_p @destination  
      end
      #Try and get file in a couple different ways. If we succeed then move on. 
      #Artifacts in your local .m2 ALWAYS take precedence over a remote artifact...
      #Unless we fail so hard we end up using mvn as a last ditched effort. 
      success = getLocalM2
      success = getRestArtifactory if ! success and ! @offline 
      success = getMaven if ! success and system( 'which mvn > /dev/null' ) 
      if ! success
        $LOG.info "[failed] #{outputFilename}"
      end
      return success
    end

    def getLocalM2 
      local_repo = "#{ENV["HOME"]}/.m2/repository"
      local_meta = "#{local_repo}/#{local_metadata_path}"
      log_prefix = "[local]  #{outputFilename}"
      success = false
      begin
        artifactory_path = get_repo_path
        artifact = "#{local_repo}/#{artifactory_path}"
        $LOG.debug "#{artifact}" 
        $LOG.debug "#{local_meta}"
        #This should really be parsing the metadata and basing how we handle it on its version
        #For now so that we're compatible with old mvn we just grab it if we found it the old way and parse only if we miss. :(
        if @version.include?("SNAPSHOT") && ! File.exists?(artifact) && File.exists?(local_meta)
          artifactory_path = get_repo_path(File.read(local_meta))
          artifact = "#{local_repo}/#{artifactory_path}"
        end
        $LOG.debug "#{log_prefix}: Copying #{artifact} to #{dest_file}"
        cp_tries = 0 
        #Its insane that cp can fail without barfing an error... 
        ##but apparantly it can so lets md5sum our way to and loop to victory (hopefully).
        #I kinda feel like the bug this fixes has do to with the ruby io bufferering and old versions of ruby... but I don't have time to delve in
        while ! success && cp_tries < 3
          FileUtils.copy(artifact,dest_file)
          dest_md5 = Digest::MD5.file("#{dest_file}").hexdigest
          src_md5  = Digest::MD5.file("#{artifact}").hexdigest 
          if dest_md5 != src_md5
            $LOG.debug "md5sum #{dest_file} #{artifact} :( #{dest_md5} == #{src_md5}" #This is insane. 
            cp_tries += 1 
            next
          end
          success = true
        end
      rescue Errno::ENOENT
      	$LOG.debug "#{log_prefix}: #{artifact} does not exist."
      rescue SystemCallError => e
        $LOG.debug "#{log_prefix}: Failed to copy file from local m2 repository."
        $LOG.debug e
      rescue NoMethodError => e
        $LOG.debug "#{log_prefix}: Something went wrong while fetching #{@artifact} #{@group} #{@version} Failed (probably while parsing the metadata in #{local_meta} its probably an old format)"
      else #Yay we got it
        if ! success 
          $LOG.debug "#{log_prefix}: Copy operation failed 3 times... Which is insane..."  
          $LOG.debug "#{log_prefix}: Deleting the 'bad' jar and moving on." 
          FileUtils.rm(dest_file)
        else 
          $LOG.debug "#{log_prefix}: Successfully copied from local m2 repository."
          $LOG.info "#{log_prefix}"
          return success
        end
      end
      return success 
    end

    def getRestArtifactory 
      log_prefix = "[remote] #{outputFilename}"
      artifactory_path = get_repo_path
      $LOG.debug "#{log_prefix}: Attempting to fetch via the artifactory rest api."
      #Loop through all the repos until something works
      @repositories.each { |repo| 
        begin
          artifactory_path = get_repo_path(restRequest(URI.parse("#{repo}/#{metadata_path}"))) if @version.include?("SNAPSHOT")
          open(dest_file,"wb") { |file|
            file.write(restRequest(URI.parse("#{repo}/#{artifactory_path}")))
          }
        rescue SocketError,RuntimeError => e # :( Maybe do better handling later. 
          $LOG.debug "#{log_prefix}: Failed to fetch Artifact #{repo}/#{artifactory_path}"  
          $LOG.debug e
          next
        end 

        #Check to make sure the md5sum of what we downloaded matches what's in the artifactory.
        begin
          artifactory_md5 = restRequest(URI.parse("#{repo}/#{artifactory_path}.md5"))
          my_md5 = Digest::MD5.file("#{dest_file}").hexdigest
        rescue SocketError, RuntimeError => e # :( Do better handling later. 
          $LOG.error "#{log_prefix}: Blew up while attempting to get md5s."
        else
          if artifactory_md5 == my_md5
            $LOG.debug "#{log_prefix}: Successfully fetched via artifactory rest api."
            $LOG.info "#{log_prefix}"
            return true 
          end
          $LOG.debug "#{log_prefix}: Remote md5 #{artifactory_md5} didn't match #{my_md5}" 
          $LOG.debug "#{log_prefix}: Deleting the 'bad' jar and moving on." 
          FileUtils.rm(dest_file)
        end
      }
      return false
    end

    #Depricated because its slow and expensive to use... leaving it here for now.
    def getMaven
      log_prefix = "[maven]  #{outputFilename}"
      
      c =  "mvn org.apache.maven.plugins:maven-dependency-plugin:2.5:get" 
      c << " -DremoteRepositories=#{@repositories.join(',').shellescape}" 
      c << " -Dtransitive=#{@transative}"
      c << " -Dartifact=" + "#{@group}:#{@artifact}:#{@version}:#{@package}".shellescape
      c << " -Ddest=#{dest_file.shellescape}"
      c << " &>/dev/null"

      if @offline
        c << " --offline"
      end

      if !@verbose
        #quiet mode is default
        c << " -q"
      end
      
      result = system( c )
      if result == false
        $LOG.error("#{log_prefix}: Failed to retrieve artifact. -- #{c}")
      else
        $LOG.info "#{log_prefix}"
      end
      return result
    end
    
    def local_metadata_path
      "#{@group.gsub(/\./,'/')}/#{@artifact}/#{@version}/maven-metadata-local.xml"
    end
    
    def metadata_path
      "#{@group.gsub(/\./,'/')}/#{@artifact}/#{@version}/maven-metadata.xml"
    end
    
    def outputFilename
      "#{@artifact}-#{@version}.#{@package}"
    end
    
    def dest_file
      File.join(@destination,outputFilename)
    end
   
    def determine_repo_artifact_name(maven_metadata)
      return @version if maven_metadata == nil
      data = XmlSimple.xml_in(maven_metadata)
      ts = data['versioning'][0]['snapshot'][0]['timestamp'][0]
      bn = data['versioning'][0]['snapshot'][0]['buildNumber'][0]
      @version.gsub(/SNAPSHOT/){ |s| "#{ts}-#{bn}" } 
    end

    def get_repo_path(meta = nil)
      path = "#{@group.gsub(/\./,'/')}/#{@artifact}/#{@version}/"
      path << "#{@artifact}-#{determine_repo_artifact_name(meta)}.#{@package}"
      path
    end
    
    def restRequest(uri)
      response = Net::HTTP.get_response(uri)
      return response.body if response.is_a?(Net::HTTPSuccess)
      $LOG.debug "#{outputFilename}: Rest request to #{uri.inspect} #{response.inspect}"
      raise "Rest request got a bad response code back [#{response.code}]" 
    end
  end

end

