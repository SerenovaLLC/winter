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

require 'simplecov'
SimpleCov.start

require 'winter'
require 'winter/cli'

describe Winter do

  describe "Unknown CLI command" do
    it "Doesn't explode" do
      #resp = `bundle exec winter badcommand`
      #puts "*** #{resp}"
      #resp.should == 'Could not find command "badcommand".'
    end
  end

  describe "validate" do
    it "Reads a local pom file" do
      begin
        lambda {
          cli = Winter::CLI.new
          cli.validate 'spec/sample_data/Winterfile'
        }.should_not raise_error
      end
    end
  end

  describe 'status' do
    it "Shows the status of any running services" do
      begin
        lambda {
          cli = Winter::CLI.new
          cli.status
        }.should_not raise_error
      end
    end
  end

  describe 'build [manifest]' do
    it "Build a service from a manifest" do
      begin
        lambda {
          args = ["build", "spec/sample_data/Winterfile"]
          cli = Winter::CLI.start( args )
        }.should_not raise_error
        Dir["run/default/libs"].include? "maven-dependency-plugin-2.5.jar"
        # TODO check that files were downloaded to 'run'
      end
    end
  end

  describe 'start and stop a service : ' do
    context "start " do
      it "Start a service" do
        begin
          lambda {
            args = ["start", "spec/sample_data/Winterfile"]
            cli = Winter::CLI.start( args )
          }.should_not raise_error
        end
      end

      it "View that the service is running" do
        begin
          lambda {
            cli = Winter::CLI.new
            cli.status
          }.should_not raise_error
        end
      end

      #it "Stop the service in [winterfile]" do
      #  lambda {
      #    args = ["stop", "spec/sample_data/Winterfile"]
      #    cli = Winter::CLI.start( args )
      #  }.should_not raise_error
      #end
    end
  end

end
