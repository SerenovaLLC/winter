# This is the Domain Specific Language definition for the Winterfile

require 'open-uri'
#require 'maven_gem'

require 'pom_fetcher'
require 'pom_spec'

module Winter
  class Dsl

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
    
    def say_hi
      puts 'hi'
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
      #spec = MavenGem::PomSpec.generate_spec(pom_doc)

    end

  end
end
