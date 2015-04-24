class Deployer::TitleForGitCommit < Deployer::FromCommandLine

  def initialize( gem_version: nil )
    super( title: "Title for \'git commit\'" , message: "Please input title for commitment" )
    @gem_version = gem_version
    @time_now = ::Time.now.strftime( "%Y%m%d_%H%M%S" )
  end

  def set
    if @gem_version.present?
      @content = "Install Gem (#{ @gem_version })"
      puts message_after_input_string
      @condition = ::Deployer.yes_no( @condition )
      super
    else
      super
    end
  end

  private

  def actual_content
    "#{ @time_now } #{ @content }"
  end

end

def set_namespace_git

  namespace :git do
  
    desc 'add to git all files under this directory'
    task :add do
      ::Deployer.process "git:add" do
        system "git add -A ."
      end
    end
  
    desc 'commit to git'
    task commit: :add do
      ::Deployer.process "git:commit" do
        system "git commit -m \"#{ ::Deployer::TitleForGitCommit.set }\""
      end
    end
  
    desc 'commit to git (amend)'
    task :commit_amend do
      ::Deployer.process "git:commit_amend" do
        system "git commit --amend -m \"#{ ::Deployer::TitleForGitCommit.set }\""
      end
    end
  
    desc 'commit to git (for Gem install or release)'
    task commit_for_gem: :add do
      ::Deployer.process "git:commit_for_gem" do
        gem_v = fetch( :new_version )
        t = ::Deployer::TitleForGitCommit.set( gem_version: gem_v )
        system "git commit -m \"#{t}\""
      end
    end
  
  end

end