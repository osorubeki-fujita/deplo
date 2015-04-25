def set_cap_namespace_gem

  namespace :gem do

    desc "Gem - Test"
    task :test do
      ::Deployer.process "gem:test" do
        system( "rake spec" )
      end
    end

    desc "Gem - Rake install"
    task :rake_install_locally do
      ::Deployer.process "gem:rake_install_locally" do
        system( "rake install" )
      end
    end

    desc "Gem - Update name of latest version"
    task :update do
      ::Deployer.process "gem:update" do
        ::File.open( fetch( :latest_version_file ) , "w:utf-8" ) do |f|
          f.print fetch( :new_version )
        end
      end
    end

    desc "Install Gem #{ fetch( :new_version ) }"
    task install_locally: :test do
      ::Deployer.process "gem:install_locally" do
        ::Deployer.yes_no( yes: ::Proc.new {
          ::Rake::Task[ "git:commit_for_gem" ].invoke
          ::Rake::Task[ "github:push" ].invoke
          ::Rake::Task[ "gem:rake_install_locally" ].invoke
        } )
      end
    end

    desc "Release Gem #{ fetch( :new_version ) }"
    task release_to_public: :install_locally do
      old_version = open( fetch( :latest_version_file ) , "r:utf-8" ).read
      ::Deployer.process "gem:release_to_public" do
        ::Deployer.yes_no( message: "Release Gem #{ fetch( :new_version ) }" , yes: ::Proc.new {
          ::Rake::Task[ "gem:update" ].invoke
          system( "rake release" )
        })
      end
      ::Deployer.process "gem:yank_old_version" do
        ::Deployer.yes_no( message: "Yank Old Gem #{ old_version }" , yes: ::Proc.new {
          system( "gem yank #{ fetch( :gem ) } -v #{ old_version }" )
        })
      end
    end

    desc "Files to check"
    task :files_to_check do
      puts "#{ fetch( :gem ) }.gemspec"
      [
        "spec.add_development_dependency \"capistrano\"" ,
        "spec.add_development_dependency \"deployer\", \">= #{ Deployer::VERSION }\"
      ].each do | str |
        puts " " * 4 + str
      end
      puts ""
      puts "#{ fetch( :gem ) }/spec/#{ fetch( :gem ) }_spec.rb"
      [
        "require \'spec_helper\'" ,
        "require \'deployer\'" ,
        "spec_filename = ::File.expand_path( ::File.dirname( __FILE__ ) )" ,
        "version = \"#{ fetch( :new_version ) }\"" ,
        "describe MetalicRatio do" ,
        "  it "has a version number \'\#\{ version \}\'" do" ,
        "    expect( ::#{ fetch( :gem ).camelize }::VERSION ).to eq( version )"
        "    expect( ::#{ fetch( :gem ).camelize }.version_check( MetalicRatio::VERSION , spec_filename ) ).to eq( true )" ,
        "  end"
      ].each do | str |
        puts " " * 4 + str
      end
    end

  end

end