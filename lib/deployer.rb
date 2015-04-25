require "deployer/version"

#--------

require "active_support"
require "active_support/core_ext"
require "versionomy"

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
    puts "-" * 32 + "Complete: #{ command }"
    puts ""
  end

  def self.version_check( version , spec_filename )
    latest_version = open( "#{ spec_filename }/../.latest_version" , "r:utf-8" ).read
    ::Versionomy.parse( MetalicRatio::VERSION ) >= ::Versionomy.parse( latest_version )
  end

end

def set_cap_tasks_from_deployer
  set_cap_consts
  set_cap_namespace_git
  set_cap_namespace_github
  set_cap_namespace_gem
end