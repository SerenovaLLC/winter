require 'winter/logger'

module Winter

  class Dependency
    attr_accessor :artifact
    attr_accessor :group
    attr_accessor :version
    attr_accessor :repositories
    attr_accessor :package
    attr_accessor :offline
    attr_accessor :transative

    def initialize
      @artifact     = nil
      @group        = nil
      @version      = 'LATEST'
      @repositories = []
      @package      = 'jar'
      @offline      = false
      @transative   = false
    end

    def getMaven
    end
  end

end

