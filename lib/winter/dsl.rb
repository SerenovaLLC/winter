# This is the Domain Specific Language definition for the Winterfile

require 'open-uri'
require 'json'
#require 'maven_gem'

require 'pom_fetcher'
require 'pom_spec'

#require 'winter/bundles'
require 'winter/constants'
require 'winter/dependency'
#require 'winter/json_util'
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
      dsl = DSL.new options
      res = dsl.eval_winterfile winterfile
      validate(res)
    end

    def eval_winterfile( winterfile, contents=nil )
      contents ||= File.open(winterfile.to_s, "rb"){|f| f.read}
      
      # set CWD to where the winterfile is located
      Dir.chdir (File.split(winterfile.to_s)[0]) do
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
      dep.offline       = @options['offline'] || @options['offline'] == 'true'
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
      dep.offline       = @options['offline'] || @options['offline'] == 'true'
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

      pom_file = MavenGem::PomFetcher.fetch(pom)
      pom_spec = MavenGem::PomSpec.parse_pom(pom_file)
      #$LOG.info pom_spec.dependencies
      pom_spec.dependencies.each do |dep|
        #$LOG.debug dep
        if dep[:scope] == 'provided'
          lib( dep[:group], dep[:artifact], dep[:version] ) 
        end
      end
    end

    def conf( dir )
      #$LOG.debug( dir << " " << File.join(WINTERFELL_DIR,RUN_DIR,'conf') )
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
