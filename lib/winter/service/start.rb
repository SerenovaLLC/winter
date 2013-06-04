require 'winter/constants'
require 'winter/logger'

module Winter
  class Service

    def initialize
      #put defaults here
      @config = {}
      @config['java_home']   = ENV['JAVA_HOME'] 
      @config['service']     = 'default'
      @config['log.level']   = 1
      @config['64bit']       = true
      @config['jvm.mx']      = '1g'
      @config['console.log'] = '/dev/null'
      @config['web.port']    = 8080
      @config['osgi.port']   = 6070
      @config['jdb.port']    = 6071
      @config['jmx.port']    = 6072

      #@config['log.dir'] = File.join(WINTERFELL_DIR,RUN_DIR,@config['service'],'logs')
    end

    def start(winterfile, options)
      tmp = DSL.evaluate winterfile, options
      tmp[:dependencies].each do |dep|
        $LOG.debug "#{dep.group}.#{dep.artifact}"
      end
      @felix = tmp[:felix]

      @config.merge! tmp[:config]
      $LOG.debug @config
      @service_dir = File.join(File.split(winterfile)[0],RUN_DIR,@config['service'])
      @config['log.dir'] = File.join(@service_dir,'logs')


      java_cmd = generate_java_invocation
      java_cmd << " > #{@config['console.log']} 2>&1"
      $LOG.debug java_cmd

      # execute
      if( File.exists?(File.join(@service_dir, "pid")) )
        $LOG.error "PID file already exists. Is the process running?"
        exit
      end
      pid_file = File.open(File.join(@service_dir, "pid"), "w")
      pid = fork do
        exec(java_cmd)
      end
      pid_file.write(pid)
      pid_file.close      

      $LOG.info "Started #{@config['service']} (#{pid})"
    end

    def find_java
      if !@config['java_home'].nil? && File.exists?(File.join(@config['java_home'],'bin','java'))
        return File.join(@config['java_home'],'bin','java')
      end
      if !ENV['JAVA_HOME'].nil? && File.exists?(File.join(ENV['JAVA_HOME'],'bin','java'))
        return File.join(ENV['JAVA_HOME'],'bin','java')
      end
      env = `env java -version 2>&1`
      if env['version']
        return "java"
      end
      raise "JRE could not be found. Please set JAVA_HOME or configure java_home."
    end

    def generate_java_invocation
      java_bin = "#{@config['java_home']}/bin/"
      java_bin = find_java

      $LOG.debug @felix
      felix_jar = File.join(@felix.destination,"#{@felix.artifact}-#{@felix.version}.#{@felix.package}")

      # start building the command
      cmd = [ "#{java_bin} -server" ]
      cmd << (@config["64bit"]==true ? " -d64 -XX:+UseCompressedOops":'')
      cmd << " -XX:MaxPermSize=256m -XX:NewRatio=3"
      cmd << " -Xmx#{@config['jvm.mx']}" 
      cmd << opt("felix.fileinstall.dir", "#{@service_dir}/#{BUNDLES_DIR}")

      config_properties = File.join(@service_dir, "conf", F_CONFIG_PROPERTIES)
      cmd << opt("felix.config.properties", "file:" + config_properties)
      cmd << opt("felix.log.level", felix_log_level(@config['log.level']))

      system_properties = File.join(@service_dir, F_SYSTEM_PROPERTIES)
      cmd << opt("felix.system.properties", "file:#{system_properties}")

      logger_properties = File.join(@service_dir, "conf", F_LOGGER_PROPERTIES)
      # TODO remove this option when the logger bundle is updated to use the classpath
      cmd << opt("log4j.configuration", logger_properties)
    
      cmd << opt("web.port",         @config["web.port"])
      cmd << opt("osgi.port",        @config["osgi.port"])
      cmd << opt("log.dir",          @config['log.dir'])
      cmd << opt("service.conf.dir", @config['service.conf.dir'])
      cmd << opt(OPT_BUNDLE_DIR,     "#{@service_dir}/bundles")
      cmd << @config["osgi.shell.telnet.ip"]?" -Dosgi.shell.telnet.ip=#{@config["osgi.shell.telnet.ip"]}":''
      #cmd.push(add_code_coverage())
      cmd << (@config["jdb.port"] ? " -Xdebug -Xrunjdwp:transport=dt_socket,address=#{@config["jdb.port"]},server=y,suspend=n" : '')
      cmd << (@config["jmx.port"] ? " -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=#{@config["jmx.port"]} -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false" : '')
      cmd << " -cp #{@service_dir}/conf:#{felix_jar} org.apache.felix.main.Main"
      cmd << " -b #{@service_dir}/libs"
      cmd << " #{@service_dir}/felix_cache"
        
      return cmd.join(" \\\n ")
      #return cmd.join(" ")
    end 

    def opt(key, value)
      return " -D#{key}=#{value}"
    end

    def felix_log_level(level)
      if level =~ /[1-4]/
        return level
      end
      if !level.is_a? String
        return 1
      end
      case level.upcase
      when "ERROR"
        return 1
      when "WARN"
        return 2
      when "INFO"
        return 3
      when "DEBUG"
        return 4
      else
        return 1
      end
  end

  end
end
