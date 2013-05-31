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

    it "Stop the service in [winterfile]" do
      lambda {
        args = ["stop", "spec/sample_data/Winterfile"]
        cli = Winter::CLI.start( args )
      }.should_not raise_error
    end
  end

  # TODO build this out after 'start'
  #describe 'stop' do
  #end

end
