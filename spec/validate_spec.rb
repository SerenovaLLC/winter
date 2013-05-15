
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
end
