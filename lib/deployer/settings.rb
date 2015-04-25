def set_cap_consts
  set :gem , fetch( :application ).gsub( /\Agem_/ , "" )
  set :latest_version_file , ::File.expand_path( "#{ fetch( :pj_dir ) }/.latest_version" )

  # Version of Gem
  require "#{ fetch( :pj_dir ) }/lib/#{ fetch( :gem ) }/version.rb"
  set :new_version , eval( "#{ fetch( :gem ).camelize }::VERSION" )
  
  require "version.rb"
end