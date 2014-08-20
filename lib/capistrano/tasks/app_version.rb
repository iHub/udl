# namespace :app_version do
# 	desc "Create App version"
# 	task :setup do
# 		on roles(:app) do
# 			run_locally do
# 				# App version from git commit message. Message must contain versioning major.minor.fix e.g 0.2.31
#     		version = capture(%{git --no-pager log master -1 --pretty=%B})
#     		version_no = version.scan(/\d+\.\d+\.\d+/).first
# 				execute %{echo "#{version_no}" > config/version}
#       end
#       execute %{echo "#{version_no}" > #{release_path}/config/version}
# 			info "app_version setup"
# 		end
# 	end
# 	before "deploy:publishing", "app_version:setup"
# end