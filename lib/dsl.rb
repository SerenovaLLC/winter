# This is the Domain Specific Language definition for the Winterfile

require 'open-uri'
require 'maven_gem'

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

    def say_hi
      puts 'hi'
    end

    def bundle( bundle, *args )
      if bundle.is_a?(Symbol)
        raise "Bundles must be URLs, paths to poms, or Strings"
      end

      #pom_doc = MavenGem::PomFetcher.fetch(bundle)
      #puts pom_doc.to_s
    end

  end
end
