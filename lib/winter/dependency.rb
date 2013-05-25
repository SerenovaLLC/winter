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
      dest_file = File.join(@destination,"#{@artifact}-#{@version}.#{@package}")

      mvn_cmd = "mvn org.apache.maven.plugins:maven-dependency-plugin:2.5:get" \
      + " -DremoteRepositories=#{@repositories.join(',')}" \
      + " -Dtransitive=#{@transative}" \
      + " -Dartifact=#{@group}:#{@artifact}:#{@version}:#{@package}" \
      + " -Ddest=#{dest_file}"

      if @offline
        mvn_cmd << " --offline"
      end

      if !@verbose
        #quiet mode
        mvn_cmd << " -q"
        #$LOG.debug mvn_cmd
      end


      result = system(mvn_cmd)
      if result == false
        $LOG.error("Failed to retrieve artifact: #{@group}:#{@artifact}:#{@version}:#{@package}")
      else
        $LOG.debug dest_file
        #$LOG.debug "#{@group}:#{@artifact}:#{@version}:#{@package}"
      end

    end
  end

end

