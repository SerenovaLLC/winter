require 'fileutils'
require 'net/http'
require 'ostruct'
require 'rexml/document'
require 'rexml/xpath'
require 'uri'

module Winter
  class MavenPom 
    class << self

      def fetch(path, options = {})
        $LOG.debug "Reading POM from #{path}" 
        fetch_pom(path, options)
      end

      def fetch_pom(path, options = {})
        path =~ /^http:\/\// ? fetch_url(path) :
          fetch_file(path)
      end

      def parse_pom(pom_doc, options = {})
        $LOG.debug "Processing POM" 
      
        pom = OpenStruct.new
        doc = REXML::Document.new(pom_doc)
      
        pom.group        = xpath_group(doc)
        pom.artifact     = xpath_text(doc, '/project/artifactId')
        pom.version      = xpath_text(doc, '/project/version') || xpath_text(doc, '/project/parent/version')
        pom.description  = xpath_text(doc, '/project/description')
        pom.url          = xpath_text(doc, '/project/url')
        pom.dependencies = xpath_dependencies(doc)
        pom.authors      = xpath_authors(doc)

        pom.name       = "#{pom.group}.#{pom.artifact}"
        pom.lib_name   = "#{pom.artifact}.rb"
        pom.gem_name   = "#{pom.name}-#{pom.version}"
        pom.jar_file   = "#{pom.artifact}-#{pom.maven_version}.jar"
        pom.remote_dir = "#{pom.group.gsub('.', '/')}/#{pom.artifact}/#{pom.version}"
        pom
      end

      private

      def fetch_url(path)
        Net::HTTP.get(URI.parse(path))
      end

      def fetch_file(path)
        File.read(path)
      end

      def xpath_text(element, node)
        first = REXML::XPath.first(element, node) and first.text
      end

      def xpath_dependencies(element)
        deps = REXML::XPath.first(element, '/project/dependencies')
        pom_dependencies = []

        if deps
          deps.elements.each do |dep|
            next if xpath_text(dep, 'optional') == 'true'

            pom_dependencies << {
              :group     => xpath_text(dep, 'groupId'),
              :artifact  => xpath_text(dep, 'artifactId'),
              :version   => xpath_text(dep, 'version'),
              :scope     => xpath_text(dep, 'scope')
            }
          end
        end

        pom_dependencies
      end

      def xpath_authors(element)
        developers = REXML::XPath.first(element, 'project/developers')

        authors = if developers
          developers.elements.map do |el|
            xpath_text(el, 'name')
          end
        end || []
      end

      def xpath_group(element)
        xpath_text(element, '/project/groupId') || xpath_text(element, '/project/parent/groupId')
      end

    end
  end
end

