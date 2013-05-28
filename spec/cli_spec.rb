require 'simplecov'
SimpleCov.start

require 'winter'
require 'winter/cli'
require 'winter/status'
require 'winter/stop'

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

  describe 'list' do
    it "Shows a list of valid services" do
      begin
        lambda {
          cli = Winter::CLI.new
          cli.list
        }.should_not raise_error
      end
    end
  end

  describe 'build [manifest]' do
    it "Build a service from a manifest" do
      begin
        lambda {
          args = ["build", "spec/sample_data/Winterfile", "--verbose"]
          cli = Winter::CLI.start( args )
        }.should_not raise_error
        Dir["run/default/libs"].include? "maven-dependency-plugin-2.5.jar"
        # TODO check that files were downloaded to 'run'
      end
    end
  end

  describe 'start [service]' do
    it "Start a service" do
      begin
        lambda {
          args = ["start", "default", "--verbose"]
          cli = Winter::CLI.start( args )
          #cli.build 'spec/sample_data/Winterfile' 
        }.should_not raise_error
        s = Winter::Service.new
        if s.status.include?('default')
          true
        else
          false
        end
      end
    end
  end

  # TODO build this out after 'start'
  describe 'stop <service>' do
    it "Stop the named service" do
      s = Winter::Service.new
      #Winter::Service.status.each do |name, status|
        #if status == 'Running'
          #find the pid file and stop it
        #end
      #end
      true
    end
  end

end
