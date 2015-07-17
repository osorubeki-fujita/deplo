require 'spec_helper'

spec_filename = ::File.expand_path( ::File.dirname( __FILE__ ) )
version = "0.2.0"

describe Deplo do
  it "has a version number \'#{ Deplo::VERSION }\'" do
    expect( Deplo::VERSION ).to eq( version )
  end

  it "has module method \"version_check\"." do
    expect( Deplo.version_check( Deplo::VERSION , spec_filename ) ).to eq( true )
  end
end
