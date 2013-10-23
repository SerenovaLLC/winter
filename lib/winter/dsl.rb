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

#This is the Domain Specific Language definition for the Winterfile

require 'open-uri'
require 'json'

require 'maven_pom'

require 'winter/constants'
require 'winter/dependency'
require 'winter/logger'
require 'winter/templates'

module Winter
  class DSL

    def initialize( options={} )
      @name         = 'default'
      @groups       = []
      @repositories = []
      @dependencies = []
      @options      = options
      @config       = {}
      @directives   = {}
      @felix        = nil
    end

    def self.evaluate( winterfile, options={} )
      # Must create instance for instance_eval to have correct scope
      if !File.exists?(winterfile)
        raise "#{winterfile} not found."
      end
      dsl = DSL.new options
      res = dsl.eval_winterfile winterfile
      validate(res)
    end

    def eval_winterfile( winterfile, contents=nil )
      contents ||= File.open(winterfile.to_s, "rb"){|f| f.read}
      
      # set CWD to where the winterfile is located
      Dir.chdir(File.split(winterfile.to_s)[0]) do
        instance_eval(contents)
      end
      
      # add default felix in context
      if !@felix   #TODO Move default version somewhere
        @felix = lib('org.apache.felix', 'org.apache.felix.main', '4.0.2')
      end

      {
        :config       => @config,
        :dependencies => @dependencies,
        :felix        => @felix,
        :directives   => @directives
      }
    end

    def self.validate( res )
      raise "Must have at least one service name." if res[:config]['service'].nil?
      res
    end

# **************************************************************************
# Winterfile DSL spec
# **************************************************************************
    
    def name( name )
      @name = @config['service'] = name
    end

    def info( msg=nil )
      $LOG.info msg
    end

    def directive( key, value=nil )
      @directives[key] = value
    end

    def lib( group, artifact, version='LATEST', *args )
      options = Hash === args.last ? args.pop : {}
      dep = Dependency.new
      dep.artifact      = artifact
      dep.group         = group
      dep.version       = version
      dep.repositories  = @repositories
      dep.package       = options[:package] || 'jar'
      dep.offline       = @options['local'] || @options['local'] == 'true'
      dep.transative    = true
      dep.destination   = File.join(Dir.getwd,RUN_DIR,@name,LIBS_DIR)
      #dep.verbose       = true

      @dependencies.push dep
      dep
    end

    def bundle( group, artifact, version='LATEST', *args )
      options = Hash === args.last ? args.pop : {}
      dep = Dependency.new
      dep.artifact      = artifact
      dep.group         = group
      dep.version       = version
      dep.repositories  = @repositories
      dep.package       = options[:package] || 'jar'
      dep.offline       = @options['local'] || @options['local'] == 'true'
      dep.transative    = false
      dep.destination   = File.join(Dir.getwd,RUN_DIR,@name,BUNDLES_DIR)
      #dep.verbose       = true

      @dependencies.push dep
      dep
    end

    def felix( group, artifact, version='LATEST', *args )
      @felix = lib( group, artifact, version, args )
    end

    def pom( pom, *args )
      if pom.is_a?(Symbol)
        raise "Poms must be URLs, paths to poms, or Strings"
      end

      pom_file = MavenPom.fetch(pom)
      pom_spec = MavenPom.parse_pom(pom_file)
      pom_spec.dependencies.each do |dep|
        $LOG.debug dep
        if dep[:scope] == 'provided'
          lib( dep[:group], dep[:artifact], dep[:version] ) 
        end
      end
    end

    def conf( dir )
      process_templates( dir, File.join(WINTERFELL_DIR,RUN_DIR,@name,'conf') )
    end

    def read( file )
      if File.exist?(file)
        @config.merge!( JSON.parse(File.read file ))
      else
        $LOG.warn "#{file} could not be found."
      end
    end

    def group(*args, &blk)
      @groups.concat args
      #$LOG.info @options['group'].split(",")
      #$LOG.info "in group " << @groups.join("::")
      if( @options['group'] \
         && @options['group'].split(",").include?(@groups.join("::")) )
        yield
      end
    ensure
      args.each { @groups.pop }
    end

    def repository( url )
      @repositories.push url
    end
    alias :repo :repository

  end
end
