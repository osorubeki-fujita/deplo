class Deplo::BranchNameForGithub < Deplo::FromCommandLine

  def initialize
    super( title: "Git Branch" , message: "Please input name of branch" , content: "master" )
  end

  def set
    while !( @condition )
      if @content == "master"
        @condition = ::Deplo.yes_no( @condition , no: ::Proc.new { @content = nil } , message: "Use branch \'master\'" )
      else
        super
      end
    end
  end

end

def set_cap_namespace_github

  namespace :github do

    desc 'push to github'
    task :push do
      ::Deplo.process "github:push" do
        github_remote_name = fetch( :github_remote_name )
        branch_name = ::Deplo::BranchNameForGithub.set
        system "git push #{ github_remote_name } #{ branch_name }"
      end
    end

    desc 'pull from github'
    task :pull do
      ::Deplo.process "github:pull" do
        github_remote_name = fetch( :github_remote_name )
        branch_name = ::Deplo::BranchNameForGithub.set
        system "git push #{ github_remote_name } #{ branch_name }"
      end
    end

  end

end
