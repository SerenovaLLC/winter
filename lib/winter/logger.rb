require 'logger'

if $LOG.nil?
  $LOG = Logger.new(STDOUT)
  #original_formatter = Logger::Formatter.new
  $LOG.level = Logger::INFO
  $LOG.formatter = proc { |severity, datetime, progname, msg|
    #original_formatter.call(severity, datetime, progname, msg.dump)
    if( severity == 'DEBUG')
      "#{severity}: #{msg} \n"
    else
      "#{msg} \n"
    end
  }
end
