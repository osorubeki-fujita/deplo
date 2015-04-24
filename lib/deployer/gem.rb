def set_namespace_gem

  namespace :gem do

    desc "Gem - Test"
    task :test do
      ::Deployer.process "gem:test" do
        system( "rake spec" )
      end
    end

    desc "Gem - Rake install"
    task :rake_install do
      ::Deployer.process "gem:install" do
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
    task install: :test do
      ::Deployer.process "gem:install" do
        ::Deployer.yes_no( yes: ::Proc.new {
          ::Rake::Task[ "git:commit_for_gem" ].invoke
          ::Rake::Task[ "github:push" ].invoke
          ::Rake::Task[ "gem:rake_install" ].invoke
          ::Rake::Task[ "gem:update" ].invoke
        } )
      end
    end

  end

end