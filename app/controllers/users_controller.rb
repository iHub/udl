class UsersController < ApplicationController
	
	before_action :signed_in_user, only: [:index, :edit, :update, :show]
	before_action :correct_user,   only: [:edit, :update]
	before_action :admin_user,     only: :destroy
	before_action :manager_user,   only: [:index]

	WELCOME_MESSAGE = "Welcome to the Umati Data Logger"

	def index
		@users = User.paginate(page: params[:page])
	end

	def new
		@user = User.new
	end

	def show
		@user = User.find(params[:id])
		@scrape_sessions = @user.scrape_sessions.paginate(page: params[:page])
	end

	def edit
  	end

	def update
		if @user.update_attributes(user_params)
		  flash[:success] = "Profile updated"
		  redirect_to @user
		else
		  render 'edit'
		end
	end

	def create
		@user = User.new(user_params)
		@user.role = "annotator"
		if @user.save
			sign_in @user
			flash[:success] = WELCOME_MESSAGE
			redirect_to @user
		else
		  render 'new'
		end
	end

	def destroy
		user = User.find(params[:id]).destroy
		flash[:success] = "User Successfully deleted."
		redirect_to users_url
	end

	#--------------------------------------

	private

		# Before filters
	    # def signed_in_user
	    # 	unless signed_in?
		   #      store_location
		   #      redirect_to signin_url, notice: "Please sign in to Access this page"
		   #  end	      
	    # end

		def correct_user
			@user = User.find(params[:id])
			redirect_to(root_url) unless current_user?(@user)
		end

		def admin_user
      		redirect_to(root_url) unless current_user.isadmin?
    	end

    	def manager_user
      		redirect_to(root_url) unless current_user.ismanager?
    	end

	    #strong parameters
		def user_params
		  params.require(:user).permit(:firstname, :lastname, :email, :password,
		                               :password_confirmation)
		end

end
