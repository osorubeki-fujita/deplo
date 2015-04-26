require 'spec_helper'

spec_filename = ::File.expand_path( ::File.dirname( __FILE__ ) )
version = "0.3.0"

describe Deployer do
  it "has a version number \'#{ Deployer::VERSION }\'" do
    expect( Deployer::VERSION ).to eq( version )
  end

  it "has module method \"version_check\"." do
    expect( Deployer.version_check( Deployer::VERSION , spec_filename ) ).to eq( true )
  end
end