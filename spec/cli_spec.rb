
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

end
