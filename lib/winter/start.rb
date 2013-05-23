require 'winter/constants'
require 'winter/logger'

module Winter
  class Service

    def initialize
      @config = {}
      @config['java_home'] = ENV['JAVA_HOME'] 
      @config['service'] = 'Example'
      @config['log.level'] = 1
      @config['web.port'] = 8080
      @config['osgi.port'] = 6070
    end

    def start(winterfile, options)
      DSL.evaluate winterfile, options

      $LOG.debug generate_java_invocation(@config,@config['service'])
    end

    def generate_java_invocation(config,service)
      java_bin = "#{config['java_home']}/bin/"
      java_bin = ""

      # start building the command
      cmd = [ "#{java_bin}java -server" ]
      #cmd.push(config["64bit"]==true ? add_64bit_flag():'')
      #cmd.push(" -XX:MaxPermSize=256m -XX:NewRatio=3")
      #cmd.push(add_memory_options())
      cmd.push(add_config_option("felix.fileinstall.dir", "#{WINTERFELL_DIR}/#{RUN_DIR}/#{config['service']}/felix_deploy"))

      config_properties = File.join(WINTERFELL_DIR, RUN_DIR, @config['service'], "conf", F_CONFIG_PROPERTIES)
      cmd.push(add_config_option("felix.config.properties", "file:" + config_properties))
      #cmd.push(add_config_option("felix.log.level", felix_log_level(@config['log.level'])))

      # determine system.properties file existence
      #system_properties = find_system_properties
      #
      system_properties = File.join(WINTERFELL_DIR, SERVICES_DIR, @config['service'], F_SYSTEM_PROPERTIES)
      cmd.push(add_config_option("felix.system.properties", "file:#{system_properties}"))

      # dertmine logger_bundle.properties location
      #logger_properties = find_logger_properties
      logger_properties = File.join(WINTERFELL_DIR, RUN_DIR, @config['service'], "conf", F_LOGGER_PROPERTIES)
      # TODO remove this option when the logger bundle is updated to use the classpath
      cmd.push(add_config_option("log4j.configuration", logger_properties))
    
      cmd.push(add_config_option("web.port",         config["web.port"]))
      cmd.push(add_config_option("osgi.port",        config["osgi.port"]))
      cmd.push(add_config_option("log.dir",          config['log.dir']))
      cmd.push(add_config_option("service.conf.dir", config['service.conf.dir']))
      cmd.push(add_config_option(OPT_BUNDLE_DIR, 
        "#{WINTERFELL_DIR}/#{RUN_DIR}/#{config['service']}/bundles"))
      cmd.push(config["osgi.shell.telnet.ip"]?add_osgi_ip(config["osgi.shell.telnet.ip"]):'')
      #cmd.push(add_code_coverage())
      #cmd.push(config["jdb.port"]?add_jdb_option(config["jdb.port"]):'')
      #cmd.push(config["jmx.port"]?add_jmx_option(config["jmx.port"]):'')
      cmd.push(add_jar())
      cmd.push(add_bundle())
      cmd.push(add_cache())
        
      return cmd.join(" \\\n ")
      #return cmd.join(" ")
    end 

    def add_jar()
      return " -cp #{WINTERFELL_DIR}/run/#{@config['service']}/conf:#{WINTERFELL_DIR}/run/#{@config['service']}/libs/org.apache.felix.main-3.0.6.jar org.apache.felix.main.Main"
    end

    def add_bundle()
      #return " -b #{WINTERFELL_DIR}/felix/bundle"
      return " -b #{WINTERFELL_DIR}/#{RUN_DIR}/#{@config['service']}/libs"
    end

    def add_cache()
      return " #{WINTERFELL_DIR}/#{RUN_DIR}/#{@config['service']}/felix_cache"
    end

    def add_config_option(key, value)
      return " -D#{key}=#{value}"
    end

  end
end
