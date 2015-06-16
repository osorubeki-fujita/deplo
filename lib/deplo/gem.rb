def set_cap_namespace_gem

  namespace :gem do

    desc "Gem - Test"
    task :test do
      ::Deplo.process "gem:test" do
        system( "rake spec" )
      end
    end

    desc "Gem - Rake install"
    task :rake_install_locally do
      ::Deplo.process "gem:rake_install_locally" do
        system( "rake install" )
      end
    end

    desc "Gem - Update name of latest version"
    task :update do
      ::Deplo.process "gem:update" do
        latest_version_file = fetch( :latest_version_file )
        unless ::File.exist?( latest_version_file )
          ::File.open( latest_version_file , "r:utf-8" ).close
        end
        ::File.open( latest_version_file , "w:utf-8" ) do |f|
          f.print fetch( :new_version )
        end
      end
    end

    desc "Install Gem #{ fetch( :new_version ) }"
    task install_locally: :test do
      ::Deplo.process "gem:install_locally" do
        ::Deplo.yes_no( yes: ::Proc.new {
          ::Rake::Task[ "git:commit_for_gem" ].invoke
          ::Rake::Task[ "github:push" ].invoke
          ::Rake::Task[ "gem:rake_install_locally" ].invoke
        } )
      end
    end

    desc "Release Gem #{ fetch( :new_version ) }"
    task release_to_public: :install_locally do
      old_version = open( fetch( :latest_version_file ) , "r:utf-8" ).read
      ::Deplo.process "gem:release_to_public" do
        ::Deplo.yes_no( message: "Release Gem #{ fetch( :new_version ) }" , yes: ::Proc.new {
          ::Rake::Task[ "gem:update" ].invoke
          system( "rake release" )
        })
      end
      ::Deplo.process "gem:yank_old_version" do
        ::Deplo.yes_no( message: "Yank Old Gem #{ old_version }" , yes: ::Proc.new {
          system( "gem yank #{ fetch( :gem ) } -v #{ old_version }" )
        })
      end
    end

    desc "Files to check"
    task :files_to_check do

      #-------- xxxx.gemspec

      ::Deplo.display_file_info_to_check(
        "#{ fetch( :gem ) }.gemspec" ,
        "spec.add_development_dependency \"capistrano\"" ,
        "spec.add_development_dependency \"deplo\", \">= #{ ::Deplo::VERSION }\""
      )

      #-------- xxxx/spec/xxxx_spec.rb

      ::Deplo.display_file_info_to_check(
        "#{ fetch( :gem ) }/spec/#{ fetch( :gem ) }_spec.rb" ,
        "require \'spec_helper\'" ,
        "require \'deplo\'" ,
        "spec_filename = ::File.expand_path( ::File.dirname( __FILE__ ) )" ,
        "version = \"#{ fetch( :new_version ) }\"" ,
        "describe #{ fetch( :gem ).camelize } do" ,
        "  it \"has a version number \\\'\#\{ version \}\\\'\" do" ,
        "    expect( ::#{ fetch( :gem ).camelize }::VERSION ).to eq( version )" ,
        "    expect( ::Deplo.version_check( ::#{ fetch( :gem ).camelize }::VERSION , spec_filename ) ).to eq( true )" ,
        "  end"
      )

      #-------- Capfile (1)

      ::Deplo.display_file_info_to_check(
        "Capfile" ,
        #
        "\# Load DSL and set up stages" ,
        "require \'capistrano/setup\'" ,
        "" ,
        "\# Include default deployment tasks" ,
        "require \'capistrano/deploy\'" ,
        "" ,
        "require \'deplo\'"
      )

      #-------- Capfile (2)

      ::Deplo.display_file_info_to_check(
        "Capfile" ,
        #
        "Rake::Task[:production].invoke" ,
        "invoke :production" ,
        "set_cap_tasks_from_deplo"
      )

      #-------- .gitignore

      gitignore_filename = ::File.expand_path( "#{ fetch( :pj_dir ) }/.gitignore" )
      latest_version_setting_in_gitignore = "/.latest_version"

      ::Deplo.display_file_info_to_check(
        ".gitignore" ,
        latest_version_setting_in_gitignore
      )

      ::Deplo.file_inclusion_check( gitignore_filename , latest_version_setting_in_gitignore , addition: true )

      #-------- version.rb

      ::Deplo.display_file_info_to_check( "lib/#{ fetch( :gem ) }/version.rb" )

      #-------- config/deploy.rb

      ::Deplo.display_file_info_to_check( "config/deploy.rb" )
      in_file = ::File.open( "#{ fetch( :pj_dir ) }/config/deploy.rb" ).read.split( /\n/ )
      regexps = [
        /\Aset \:application/ ,
        /\Aset \:repo_url/ ,
        /\Aset \:pj_dir/ ,
        /\Aset \:github_remote_name/ ,
        /\Aset \:deploy_to ?, \'\/\'/
      ]

      condition = regexps.all? { | regexp |
        included_in_file = in_file.any? { | row | regexp === row }
        unless included_in_file
          puts "No row matched with #{ regexp.to_s }"
        end

        included_in_file
      }
      puts ""

      if condition
        puts "*** All Capistrano constants are set. (maybe each constant itself is not valid)"
      else
        puts "[!] Some Capistrano constants are not set."
      end
    end

  end

end
