require 'winter/constants'
require 'winter/logger'

module Winter
  class Service

    def validate( winterfile='Winterfile', options={} )
      DSL.evaluate winterfile, options
    end

  end
end
