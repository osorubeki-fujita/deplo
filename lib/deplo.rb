require "deplo/version"

#--------

require "active_support"
require "active_support/core_ext"
require "versionomy"

#--------

require_relative 'deplo/set_cap_consts'

require_relative 'deplo/yes_no'
require_relative 'deplo/from_command_line'
require_relative 'deplo/display_file_info_to_check'

require_relative 'deplo/git'
require_relative 'deplo/github'
require_relative 'deplo/gem'

module Deplo

  def self.process( command )
    puts "=" * 64
    puts ""
    puts command
    puts ""
    yield
    puts ""
    puts "-" * 32 + "Complete: #{ command }"
    puts ""
  end

  def self.version_check( version , spec_filename )
    latest_version = open( "#{ spec_filename }/../.latest_version" , "r:utf-8" ).read
    ::Versionomy.parse( version ) > ::Versionomy.parse( latest_version )
  end

  def self.file_inclusion_check( filename , str , addition: false )
    if ::File.open( filename , "r:utf-8" ).read.split( /\n/ ).include?( str )
      puts "*** \"#{ str }\" is already included in \"#{ ::File.basename( filename ) }\"."
    elsif addition
      puts "[!] \"#{ str }\" is not included yet in \"#{ ::File.basename( filename ) }\"."
      ::File.open( filename , "a:utf-8" ) do |f|
        f.print( "\n" * 2 )
        f.print( str )
      end
      puts ""
      send( __method__ , filename , str , addition: true )
      puts "[!] \"#{ str }\" is added to \"#{ ::File.basename( filename ) }\"."
    end
    puts ""
  end

end

def set_cap_tasks_from_deplo( cap_consts: true )
  if cap_consts
    set_cap_consts
  end

  set_cap_namespace_git
  set_cap_namespace_github
  set_cap_namespace_gem
end