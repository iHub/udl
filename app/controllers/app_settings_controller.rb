class AppSettingsController < ApplicationController
  
	before_action :admin_user,     only: [:index, :edit, :create]
	before_action :manager_user,   only: [:index, :edit]

	def index
		@app_setting = AppSetting.last
	end

	def edit
		@app_setting = AppSetting.last
	end

	def new
		@app_setting = AppSetting.new
	end

	def show
		@app_setting = AppSetting.last
	end
	
	def create
		@app_setting = AppSetting.new(app_setting_params)
		if @app_setting.save
			flash[:success] = "Settings Created"
			render	'index'
		else
			render 'new'
		end	
	end

	def update
		@app_setting = AppSetting.find(params[:id])
		
		if @app_setting.update_attributes(app_setting_params)
		  flash[:success] = "Settings updated"
		  redirect_to app_setting_path
		else
		  flash[:danger] = "Unable to Edit"
		  render 'edit'
		end
	end
	
	#--------------------------------------

	private

		def admin_user
      		redirect_to(root_url) unless current_user.isadmin?
    	end

    	def manager_user
      		redirect_to(root_url) unless current_user.ismanager?
    	end

	    #strong parameters
		def app_setting_params
		  params.require(:app_setting).permit(	:app_name, 
							:welcome_message, 
							:fb_app_name, 
							:fb_app_id,
							:fb_app_secret,
							:fb_app_access_token)
		end

end
