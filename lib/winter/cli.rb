require 'thor'
#autoload :DSL,      'winter/dsl'
require 'winter/dsl'
require 'winter/stop'
require 'winter/status'
require 'winter/list'

module Winter
  class CLI < Thor

    desc "validate <Winterfile>", "(optional) Check the configuration files"
    def validate( winterfile='Winterfile' )
      DSL.evaluate winterfile
    end

    desc "stop <service>", "Stop the named service"
    def stop(service)
      s = Winter::Service.new
      s.stop service
    end

    desc "list", "List available services"
    def list
      s = Winter::Service.new
      puts "\nValid services:"
      s.list.each do |i|
        puts " #{i}"
      end
      puts ""
    end

    desc "status", "Show status of available services"
    def status
      s = Winter::Service.new
      s.status.each do |service, status|
        puts " #{service} : #{status}"
      end
    end

  end #class
end #module

