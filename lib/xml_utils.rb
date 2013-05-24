require 'rexml/document'
require 'rexml/xpath'

module MavenGem
  module XmlUtils
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
