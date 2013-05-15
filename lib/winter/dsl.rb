# This is the Domain Specific Language definition for the Winterfile

require 'open-uri'
#require 'maven_gem'

require 'pom_fetcher'
require 'pom_spec'

module Winter
  class DSL

    def initialize
      @groups = []
    end

    def self.evaluate( winterfile )
      # Must create instance for instance_eval to have correct scope
      dsl = new
      dsl.eval_winterfile winterfile
    end

    def eval_winterfile( winterfile, contents=nil )
      contents ||= File.open(winterfile.to_s, "rb"){|f| f.read}
      instance_eval(contents)
    end

# **************************************************************************
# Winterfile DSL spec
# **************************************************************************
    
    def info( msg=nil )
      puts msg
    end

    def bundle( bundle, *args )
      if bundle.is_a?(Symbol)
        raise "Bundles must be URLs, paths to poms, or Strings"
      end

      pom = MavenGem::PomFetcher.fetch(bundle)
      pom_spec = MavenGem::PomSpec.parse_pom(pom)
      #puts pom.to_s
      pom_spec.dependencies.each do |dep|
        puts dep
      end
    end

    def group(*args, &blk)
      @groups.concat args
      yield
    ensure
      args.each { @groups.pop }
    end

  end
end
