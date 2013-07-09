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


#@wf_dir = 
WINTERFELL_DIR = ENV['WINTERFELL_DIR'] || '.'
#RUN_DIR = File.join(WINTERFELL_DIR,"run") || 'run'

SERVICES_DIR        = "services"
RUN_DIR             = "run"
BUNDLES_DIR         = "bundles"
LIBS_DIR            = "libs"
DEFAULT_CONF_DIR    = "defaults"
TEMPLATES_DIR       = "templates"
DAEMONTOOLS_DIR     = "/service"
OPT_BUNDLE_DIR      = "bundle.dir"
F_CONFIG_PROPERTIES = "config.properties"
F_SYSTEM_PROPERTIES = "system.properties"
F_LOGGER_PROPERTIES = "logger_bundle.properties"
F_LOG4J_PROPERTIES  = "log4j.properties"
F_LOGBACK_XML       = "logback.xml"
