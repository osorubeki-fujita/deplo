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

      #-------- xxxx.gemspec

      ::Deployer.display_file_info_to_check(
        "#{ fetch( :gem ) }.gemspec" ,
        "spec.add_development_dependency \"capistrano\"" ,
        "spec.add_development_dependency \"deployer\", \">= #{ Deployer::VERSION }\""
      )

      #-------- xxxx/spec/xxxx_spec.rb

      ::Deployer.display_file_info_to_check(
        "#{ fetch( :gem ) }/spec/#{ fetch( :gem ) }_spec.rb" ,
        "require \'spec_helper\'" ,
        "require \'deployer\'" ,
        "spec_filename = ::File.expand_path( ::File.dirname( __FILE__ ) )" ,
        "version = \"#{ fetch( :new_version ) }\"" ,
        "describe #{ fetch( :gem ).camelize } do" ,
        "  it \"has a version number \'\#\{ version \}\'\" do" ,
        "    expect( ::#{ fetch( :gem ).camelize }::VERSION ).to eq( version )" ,
        "    expect( ::#{ fetch( :gem ).camelize }.version_check( MetalicRatio::VERSION , spec_filename ) ).to eq( true )" ,
        "  end"
      )

      #-------- Capfile (1)

      ::Deployer.display_file_info_to_check(
        "Capfile" ,
        #
        "\# Load DSL and set up stages" ,
        "require \'capistrano/setup\'" ,
        "" ,
        "\# Include default deployment tasks" ,
        "require \'capistrano/deploy\'" ,
        "" ,
        "\# The gem \'deployer\' is not released on RubyGems" ,
        "require \'deployer\'"
      )

      #-------- Capfile (2)

      ::Deployer.display_file_info_to_check(
        "Capfile" ,
        #
        "Rake::Task[:production].invoke" ,
        "invoke :production" ,
        "set_cap_tasks_from_deployer"
      )

      #-------- .gitignore

      ::Deployer.display_file_info_to_check(
        ".gitignore" ,
        ".latest_version"
      )

      if ::File.open( latest_version_file , "r:utf-8" ).read.split( /\n/ ).include?( ".latest_version" )
        puts "*** \".latest_version\" is already included in \".gitignore\"."
      else
        puts "[!] \".latest_version\" is not included yet in \".gitignore\"."
      end

      #-------- version.rb

      ::Deployer.display_file_info_to_check( "version.rb" )

      #-------- config/deploy.rb

      ::Deployer.display_file_info_to_check( "config/deploy.rb" )
      in_file = ::File.expand_path( "#{ fetch( :pj_dir ) }/config/deploy.rb" ).read.split( /\n/ )
      regexps = [
        /\Aset \:application/ ,
        /\Aset \:repo_url/ ,
        /\Aset \:pj_dir/ ,
        /\Aset \:github_remote_name/ ,
        /\Aset \:deploy_to +?, \'\/\'/
      ]
      condition = regexps.all? { | regexp |
        in_file.any? { | row | regexp === row }
      }
      if condition
        puts "*** All Capistrano constants are set. (maybe each constant itself is not valid)"
      else
        puts "[!] Some Capistrano constants are not set."
      end
    end

  end

end