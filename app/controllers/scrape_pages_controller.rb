class ScrapePagesController < ApplicationController

	before_action :graph, only: [:show, :create]
	before_action :scrape_frequency_options, except: [:index, :show]
	
	

	def index
		@scrape_session = ScrapeSession.find(params[:scrape_session_id])
    	@scrape_pages = @scrape_session.scrape_pages
    	@page_number = params[:page]
	end

	def edit
		@scrape_session = ScrapeSession.find(params[:scrape_session_id])
    	@scrape_page = @scrape_session.scrape_pages.find(params[:id])
	end

	def new
		@scrape_session = ScrapeSession.find(params[:scrape_session_id])
    	@scrape_page = @scrape_session.scrape_pages.build
	end

	def create
		logger.debug "params[:scrape_session_id] => #{params[:scrape_session_id]}"
		@scrape_session = ScrapeSession.find(params[:scrape_session_id])
    	@scrape_page = @scrape_session.scrape_pages.build(scrape_page_params)

    	@scrape_page.continous_scrape 			= params[:scrape_page][:continous_scrape]
    	@scrape_page.override_session_settings  = params[:scrape_page][:override_session_settings]

    	logger.debug "params[:scrape_page][:continous_scrape] => #{params[:scrape_page][:continous_scrape]}"
    	logger.debug "@scrape_page.continous_scrape => #{@scrape_page.continous_scrape}"

    	if has_app_access_token?
    		valid_url = @scrape_page.valid_page_url(@scrape_page.page_url, @scrape_session.id)
		else
			flash.now[:danger] = "Please initialize the application to continue"			
			redirect_to new_app_setting_path and return
		end

    	# valid_init_scrape = @scrape_page.valid_init_scrape_date(@scrape_page.initial_scrape_start, @scrape_page.initial_scrape_end)

    	if valid_url == "valid"		# valid_page_url

    		logger.debug "valid page url"
    		@scrape_page.scrape_frequency = frequency_minutes params[:scrape_page][:scrape_frequency_select]
    		@scrape_page.next_scrape_date = Time.now + @scrape_page.scrape_frequency

    		# logger.debug "------------------------------------------------"
    		# logger.debug "@scrape_page.next_scrape_date => #{@scrape_page.next_scrape_date}"


			if @scrape_page.save 		# has been saved?
				logger.debug "page saved;"

				success_message = "Your page has been added to the Session!"
				# if valid_init_scrape == "true"  # should i scrape?
					
				# 	logger.debug "initial scrape is valid"
				# 	logger.debug "page saved; befor delay"
				# 	# delayed_job stuff
				# 	@scrape_page.init_scrape_start
				# 	# ScrapePage.delay().init_scrape_start(params[:id])

				# 	# @scrape_page.delay(queue: "initscrape").init_scrape_start
				# 	success_message += " Comments are being collected... "
				# 	logger.debug "page saved; after delay"
				# end

				flash[:success] = success_message
				redirect_to scrape_session_scrape_pages_path

			else  # i didnt save, render form and try again
				flash[:danger] = @scrape_page.errors.inspect
				render 'new'
			end

   #  		if valid_init_scrape == "true" || valid_init_scrape == "false"
	  #   		logger.debug "is valid_page_url && is valid_init_scrape"

			# else 		# the dates are invalid, try again
			# 	flash[:danger] = valid_init_scrape
			# 	render 'new'
			# end

    	elsif valid_url == "duplicate"		# invalid page because of duplication
    		logger.debug "duplicate page"
    		flash.now[:danger] =  "DUPLICATE: The page \" #{@scrape_page.page_url}\" already exists in this Session."
			render 'new'
		else								# invalid page - doesn't exist or koala error
			logger.debug "invalid url"
			flash.now[:danger] =  valid_url
			render 'new'
		end # @valid_page_url
	end


	def update    
		@scrape_session = ScrapeSession.find(params[:scrape_session_id])
		if @scrape_page.update_attributes(question_params)
			flash[:success] = "Your Page has been updated."
			redirect_to scrape_session_scrape_pages_path
		else
			render edit_scrape_session_scrap_page_path(@scrape_page)
		end
	end

	def show
		@scrape_session = ScrapeSession.find(params[:scrape_session_id])
		
		@scrape_page = @scrape_session.scrape_pages.find(params[:id])

		@fb_posts = @scrape_page.fb_posts.paginate(page: params[:page])

		@page_number = params[:page]

		@selected_posts = {}
		@selected_posts[:source] = "Page"

		@search = FbPost.search(params[:q])
    	@search.build_condition
    	
	end



	def destroy
		@scrape_session = ScrapeSession.find(params[:scrape_session_id])
		scrape_page = @scrape_session.scrape_pages.find(params[:id]).destroy 
		flash[:success] = "Page Deleted!"
		redirect_to scrape_session_scrape_pages_path
	end

	############################################################
	
	private

		def access_token			
			"CAAI9jQBuPWwBAFQTU7KZATPhEEjMi0RjZBI7ZBXH5J8QtRSnqBxjMZCAl8DyiHbQd4jNrV6TMJgKDbUIiA8XzsCaomrubFxpOqRpNnirwIAZATYHW69ZCvOT33oegkPcUjDsbqoXxrCg2A254owUBS2UDPBo6bL9wTWK0glXvjUM6Kw5YRRIK3CQUDJX4sTwALHEh21C5lNwZDZD"
		end

		def has_app_access_token?
			has_settings = AppSetting.last
			if !has_settings.nil?
				return true if !has_settings.fb_app_access_token.nil? 		
			end
		end

		def graph
			graph ||= Koala::Facebook::API.new(access_token)
		end

		def frequency_minutes(scrape_frequency_select)
			frequency = case scrape_frequency_select
				when "10 Minutes"	then 10.minutes.to_i
				when "30 Minutes"	then 30.minutes.to_i
				when "1 Hour"		then 1.hour.to_i
				when "3 Hours"		then 3.hours.to_i
				when "6 Hours"		then 6.hours.to_i
				when "12 Hours"		then 12.hours.to_i
				when "Daily"		then 1.day.to_i
				when "Every 3 Days"	then 3.days.to_i
				when "Weekly"		then 1.week.to_i
				else  10.minutes.to_i
			end
		end

		# scrape page with given url
		# def	scrape_this_page(page_url, end_scrape_date)
			
		# 	@get_next_page = false
		# 	@request_page_count = 0

		# 	@page_feed = graph.get_connections(page_url, "feed")
			
		# 	logger.debug "@get_next_page = #{@get_next_page}"

		# 	get_facebook_posts @page_feed, end_scrape_date

		# 	logger.debug "we are back in block scrape this page after first get_facebook_posts method run"
		# 	logger.debug "After first run: @get_next_page = #{@get_next_page}"

		# 	until @get_next_page == false
		# 		logger.debug  "@get_next_page block: and @get_next_page = #{@get_next_page}"
		# 		@request_page_count +=1
		# 		next_page_feed = @page_feed.next_page
		# 		get_facebook_posts next_page_feed, end_scrape_date
		# 	end
		# end

		# def get_facebook_posts(current_page_feed, end_scrape_date)
		# 	logger.debug "running get_facebook_posts method"
		# 	current_page_feed.each do |message_object|
		# 		if !message_object["comments"].nil?
		# 			message_object["comments"]["data"].each do |comment|
		# 				# @init_scrape_post_count +=1 			
						
		# 				comment_created_at = comment["created_time"].to_datetime

		# 				end_scrape_date = 10.minutes.ago  # hard code limit for scrape page end date

		# 				logger.debug "comment_created_at #{comment_created_at.strftime("%I:%M %p, %b %e %Y")}"
		# 				logger.debug "end_scrape_date #{end_scrape_date.strftime("%I:%M %p, %b %e %Y")}"
		# 				logger.debug "date compare: (comment_created_at > end_scrape_date) => #{(comment_created_at > end_scrape_date)}"
		# 				logger.debug "@scrape_page.id => #{@scrape_page.id}"

		# 				if (comment_created_at > end_scrape_date)
		# 					logger.debug "in the block if(comment_created_at < end_scrape_date)"
		# 					this_comment = {}
		# 					this_comment[:comment_id] 	 	 = comment["id"] 
		# 					this_comment[:from_user_id]  = comment["from"]["id"]
		# 					this_comment[:from_user_name] 	 = comment["from"]["name"]
		# 					this_comment[:message]  = comment["message"]
		# 					this_comment[:created_time]	 = comment_created_at
		# 					this_comment[:scrape_page_id]	 = @scrape_page.id

		# 					@get_next_page = true

		# 					@facebook_post = @scrape_page.facebook_posts.build(this_comment)

		# 					if @facebook_post.save
		# 						@init_scrape_post_count +=1
		# 						logger.debug "SAVED. @init_scrape_post_count = #{@init_scrape_post_count}"
		# 					end

		# 				else 
		# 					logger.debug "!(comment_created_at < end_scrape_date) so setting get_next_page to false"
		# 					@get_next_page = false
		# 				end
		# 			end # message_object each
		# 		end # if not nil
		# 	end # current page feed main block
		# 	logger.debug "@init_scrape_post_count: #{@init_scrape_post_count}"
		# 	logger.debug "@get_next_page : #{@get_next_page}"
		# end

		def scrape_frequency_options
			scrape_frequency_options    = []
			scrape_frequency_options[1] = "10 Minutes"
			scrape_frequency_options[2] = "30 Minutes"
			scrape_frequency_options[3] = "1 Hour"
			scrape_frequency_options[4] = "3 Hours"
			scrape_frequency_options[5] = "6 Hours"
			scrape_frequency_options[6] = "12 Hours"
			scrape_frequency_options[7] = "Daily"
			scrape_frequency_options[8] = "Every 3 Days"
			scrape_frequency_options[9] = "Weekly"
			@scrape_frequencies = scrape_frequency_options
		end

		# strong params
	    def scrape_page_params
	      params.require(:scrape_page).permit(:page_url, 
									      	  # :scrape_frequency,
									      	  :scrape_frequency_select,
									      	  :override_session_settings,
									      	  :next_scrape_date,
									      	  :continous_scrape )
	    end

end
