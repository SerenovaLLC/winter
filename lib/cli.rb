require 'thor'
require 'lib/dsl'

module Winter
  class CLI < Thor

    desc "validate", "Check the configuration files"
    def validate( winterfile='Winterfile' )
      Dsl.evaluate winterfile
    end

  end #class
end #module

