require 'winter/constants'
require 'winter/logger'

module Winter
  class Service

    def build(winterfile, options)
      #dsl = DSL.new options
      $LOG.debug (DSL.evaluate winterfile, options)
    end

  end
end
