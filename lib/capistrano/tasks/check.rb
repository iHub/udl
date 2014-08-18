namespace :check do
  desc "Make sure local git is in sync with remote."
  task :revision do
    on roles (:web) do
      unless `git rev-parse HEAD` == `git rev-parse origin/#{fetch(:branch)}`
        puts "WARNING: HEAD is not the same as origin/#{fetch(:branch)}"
        puts "Run `git push` to sync changes."
        exit
      end
    end
  end
  before "deploy:starting", "check:revision"
  # before "deploy:migrations", "check:revision"
  # before "deploy:cold", "check:revision"

  desc "Check that we can access everything"
  task :permissions do
    on roles(:all) do |host|
      if test("[ -w #{fetch(:deploy_to)} ]")
        info "#{fetch(:deploy_to)} is writable on #{host}"
      else
        error "#{fetch(:deploy_to)} is not writable on #{host}"
      end
    end
  end

  desc "Check if agent forwarding is working"
  task :forwarding do
    on roles(:all) do |h|
      execute 'ssh-add -l'
      if test("env | grep SSH_AUTH_SOCK ; ssh-add -l")
        info "Agent forwarding is up to #{h}"
      else
        error "Agent forwarding is NOT up to #{h}"
      end
    end
  end

  desc "Try upload the agent etc to server"
  task :ssh_agent do
    on roles(:all) do |h|

      execute 'ssh -T git@bitbucket.org'
    end
  end

  task :interactive do
    on roles(:all) do
      info capture("[[ $- == *i* ]] && echo 'Interactive' || echo 'Not interactive'")
    end
  end
  task :login do
    on roles(:all) do
      info capture("shopt -q login_shell && echo 'Login shell' || echo 'Not login shell'")
    end
  end

end