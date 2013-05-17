
require 'winter'
require 'winter/cli'

describe Winter do
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
          args = ["build", "spec/sample_data/Winterfile", "--verbose"]
          cli = Winter::CLI.start( args )
          #cli.build 'spec/sample_data/Winterfile' 
        }.should_not raise_error
        # TODO check that files were downloaded to 'run'
      end
    end
  end

  # TODO build this out after 'start'
  describe 'stop <service>' do
    it "Stop the named service" do
      true
    end
  end

end
