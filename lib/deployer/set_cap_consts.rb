def set_cap_consts
  set :gem , fetch( :application ).gsub( /\Agem_/ , "" )
  set :latest_version_file , ::File.expand_path( "#{ fetch( :pj_dir ) }/.latest_version" )

  # Version of Gem
  dirname = [ fetch( :pj_dir ) , :lib , fetch( :gem ).gsub( /::/ , "_" ) ].map( &:to_s ).join( "/" )
  require "#{ dirname }/version.rb"

  set :new_version , eval( "#{ fetch( :gem ).camelize }::VERSION" )

  require "#{ ::File.dirname( __FILE__ ) }/version.rb"
end