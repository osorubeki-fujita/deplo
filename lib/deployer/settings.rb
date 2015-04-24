def set_consts
  set :gem , fetch( :application ).gsub( /\Agem_/ , "" )
  set :latest_version_file , ::File.expand_path( "#{ fetch( :pj_dir ) }/LatestVersion" )

  require "#{ fetch( :pj_dir ) }/lib/#{ fetch( :gem ) }/version.rb"
  set :new_version , eval( "#{ fetch( :gem ).camelize }::VERSION" )
end