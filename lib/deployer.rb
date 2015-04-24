require "deployer/version"

#--------

require "active_support"
require "active_support/core_ext"

#--------

require_relative 'deployer/settings'

require_relative 'deployer/yes_no'
require_relative 'deployer/from_command_line'

require_relative 'deployer/git'
require_relative 'deployer/github'
require_relative 'deployer/gem'

module Deployer

  def self.process( command )
    puts "=" * 64
    puts command
    puts ""
    yield
    puts ""
    puts "Complete!"
    puts ""
  end

end

def cap_set
  set_consts
  set_namespace_git
  set_namespace_github
  set_namespace_gem
end