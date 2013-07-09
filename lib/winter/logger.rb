# Copyright 2013 LiveOps, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not 
# use this file except in compliance with the License.  You may obtain a copy 
# of the License at:
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software 
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT 
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the 
# License for the specific language governing permissions and limitations 
# under the License.

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
