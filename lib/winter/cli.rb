require 'thor'
#autoload :DSL,      'winter/dsl'
require 'winter/dsl'
require 'winter/logger'
require 'winter/version'
require 'winter/service/build'
require 'winter/service/start'
require 'winter/service/status'
require 'winter/service/stop'
require 'winter/service/validate'

module Winter
  class CLI < Thor

    desc "validate [Winterfile]", "(optional) Check the configuration files"
    method_option :group, :desc => "Config group"
    method_option :debug,   :desc => "Set log level to debug."
    def validate( winterfile='Winterfile' )
      begin
        $LOG.level = Logger::DEBUG if options[:debug]
        s = Winter::Service.new
        s.validate winterfile, options
        $LOG.info "#{winterfile} is valid." 
      rescue Exception=>e
        $LOG.error "#{winterfile} is invalid." 
        $LOG.debug e
      end
    end

    desc "version", "Display version information."
    def version
      $LOG.info VERSION
    end

    desc "start [Winterfile]", "Start the services in [Winterfile] "
    method_option :group,   :desc => "Config group"
    #method_option :verbose, :desc => "Verbose maven output"
    method_option :debug,   :desc => "Set log level to debug."
    method_option :console, :desc => "Send console output to [file]",
      :default => "/dev/null", :aliases => "--con"
    def start(winterfile='Winterfile')
      $LOG.level = Logger::DEBUG if options[:debug]
      s = Winter::Service.new
      s.start winterfile, options
    end

    desc "stop [Winterfile]", "Stop the services in [Winterfile]"
    method_option :group,   :desc => "Config group"
    def stop(winterfile='Winterfile')
      s = Winter::Service.new
      s.stop winterfile, options
    end

    desc "status", "Show status of available services"
    def status
      s = Winter::Service.new
      s.status.each do |service, status|
        $LOG.info " #{service} : #{status}"
      end
    end

    desc "build [Winterfile]", "Build a service from a Winterfile"
    method_option :group,   :desc => "Config group"
    method_option :verbose, :desc => "Verbose maven output"
    method_option :debug,   :desc => "Set log level to debug."
    method_option :local,   :desc => "Resolve dependencies only from local repository"
    method_option :getdependencies, :desc => "Pull dependencies from all repositories", :default => true
    def build( winterfile='Winterfile' )
      $LOG.level = Logger::DEBUG if options[:debug]
      s = Winter::Service.new
      s.build( winterfile, options )
    end

  end #class
end #module

