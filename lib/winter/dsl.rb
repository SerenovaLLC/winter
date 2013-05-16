# This is the Domain Specific Language definition for the Winterfile

require 'open-uri'
#require 'maven_gem'

require 'pom_fetcher'
require 'pom_spec'

require 'winter/logger'

module Winter
  class DSL

    def initialize( options={} )
      @name         = 'default'
      @groups       = []
      @repositories = []
      @options      = options
    end

    def self.evaluate( winterfile, options={} )
      # Must create instance for instance_eval to have correct scope
      dsl = DSL.new options
      dsl.eval_winterfile winterfile
    end

    def eval_winterfile( winterfile, contents=nil )
      contents ||= File.open(winterfile.to_s, "rb"){|f| f.read}
      # set CWD to where the winterfile is located
      Dir.chdir (File.split(winterfile.to_s)[0]) do
        instance_eval(contents)
      end
    end

# **************************************************************************
# Winterfile DSL spec
# **************************************************************************
    
    def name( name )
      @name = name
    end

    def info( msg=nil )
      $LOG.info msg
    end

    def bundle( group, artifact, version, *args )

    end

    def pom( pom, *args )
      if pom.is_a?(Symbol)
        raise "Poms must be URLs, paths to poms, or Strings"
      end

      pom_file = MavenGem::PomFetcher.fetch(pom)
      pom_spec = MavenGem::PomSpec.parse_pom(pom_file)
      #$LOG.info pom.to_s
      pom_spec.dependencies.each do |dep|
        $LOG.debug dep
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
