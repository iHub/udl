namespace :assets do
  desc "Precompile assets on local machine and upload them to the server."
  task :precompile, roles: :web, except: {no_release: true} do
    run_locally "bundle exec rake assets:precompile"
    find_servers_for_task(current_task).each do |server|
    	run_locally "rsync -vr public/assets #{user}@#{server.host}:#{shared_path}/"        
    end
  end

    # task :precompile, :roles => :web, :except => { :no_release => true } do
    #   from = source.next_revision(current_revision)
    #   if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
    #     run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
    #   else
    #     logger.info "Skipping asset pre-compilation because there were no asset changes"
    #   end
    #   # after "deploy:"
    # end


  desc "Precompile assets from the server and copy them to the local machine"
  task :recompile, roles: :web, except: {no_release: true} do
    find_servers_for_task(current_task).each do |server|
    	run_locally "rsync -vr #{user}@#{server.host}:#{shared_path}/assets/ public/awesome"        
    end
  end

  desc "Precompile assets from the server and copy them to the local machine"
  task :images, roles: :web, except: {no_release: true} do
    find_servers_for_task(current_task).each do |server|
      run_locally "rsync -vr public/assets #{user}@#{server.host}:#{shared_path}/"        
    end
  end
end