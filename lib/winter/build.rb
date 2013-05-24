require 'winter/constants'
require 'winter/logger'

module Winter
  class Service

    def build(winterfile, options)
      #dsl = DSL.new options
      tmp = DSL.evaluate winterfile, options
      dependencies = tmp[:dependencies]
      $LOG.debug dependencies

      dependencies.each do |dep|
        dep.getMaven
      end
    end

  end
end
