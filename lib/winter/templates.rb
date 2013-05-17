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
