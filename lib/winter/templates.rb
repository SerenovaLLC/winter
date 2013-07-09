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

require 'winter/logger'
require 'erb'

def process_templates(source_templates, destination_dir)
  #$LOG.debug "'#{source_templates}' -> #{destination_dir}"
  Dir.glob(File.join(source_templates, "**", "*.erb")) do |tmpl|
    result = ERB.new(File.open(tmpl).read).result(binding)
    dest = destination_dir + tmpl.sub(%r{#{source_templates}},"").sub(/\.erb$/, "")
    #$LOG.debug "Processing: #{dest}"
    FileUtils.mkpath File.dirname(dest)
    File.new(dest,'w').write(result)
  end
end
