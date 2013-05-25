require 'thor'
#autoload :DSL,      'winter/dsl'
require 'winter/build'
require 'winter/dsl'
require 'winter/list'
require 'winter/logger'
require 'winter/start'
require 'winter/status'
require 'winter/stop'

module Winter
  class CLI < Thor

    desc "validate <Winterfile>", "(optional) Check the configuration files"
    method_option :group, :desc => "Config group"
    def validate( winterfile='Winterfile' )
      DSL.evaluate winterfile, options
    end

    desc "list", "List available services"
    def list
      s = Winter::Service.new
      $LOG.info "Valid services:"
      s.list.each do |i|
        $LOG.info " #{i}"
      end
      $LOG.info ""
    end

    desc "start [service]", "Start the named service"
    method_option :group,   :desc => "Config group"
    method_option :verbose, :desc => "Verbose maven output"
    def start(service='Winterfile')
      s = Winter::Service.new
      s.start service, options
    end

    desc "stop [service]", "Stop the named service"
    def stop(service='Winterfile')
      s = Winter::Service.new
      s.stop service
    end

    desc "status", "Show status of available services"
    def status
      s = Winter::Service.new
      s.status.each do |service, status|
        $LOG.info " #{service} : #{status}"
      end
    end

    desc "build <manifest>", "Build a service from a manifest"
    method_option :group,   :desc => "Config group"
    method_option :verbose, :desc => "Verbose maven output"
    method_option :local,   :desc => "Resolve dependencies only from local repository"
    method_option :getdependencies, :desc => "Pull dependencies from all repositories", :default => true
    def build( winterfile='Winterfile' )
      s = Winter::Service.new
      s.build( winterfile, options )
    end

  end #class
end #module

