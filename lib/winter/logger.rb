require 'logger'

if $LOG.nil?
  $LOG = Logger.new(STDOUT)
  original_formatter = Logger::Formatter.new
  $LOG.formatter = proc { |severity, datetime, progname, msg|
    #original_formatter.call(severity, datetime, progname, msg.dump)
    "#{msg} \n"
  }
end
