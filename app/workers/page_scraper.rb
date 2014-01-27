class PageScraper

	@queue = :page_scrape_queue

	TOKEN = "630625760329068|ALYvpBPfa_0YzbpKpstk8wc8rw4"

	def self.perform(scrape_page_id)
		logger.debug "IN Resque worker : self.perform"
		scrape_page = ScrapePage.find(scrape_page_id)
		graph = Koala::Facebook::API.new(TOKEN)
		page_feed = graph.get_connections(page_url, "feed", :fields => "comments")
		get_fb_comments page_feed, end_scrape_date
	end

	def get_fb_comments(current_page_feed, end_scrape_date)
		logger.debug "IN Resque worker : running get_fb_comments method"
		@init_scrape_post_count = 0 	
		current_page_feed.each do |message_object|
			if !message_object["comments"].nil?
				message_object["comments"]["data"].each do |comment|					
					
					comment_created_at = comment["created_time"].to_datetime

					if scrape_frequency.nil? 
						end_scrape_date = 10.minutes.ago  # hard code limit for scrape page end date
					else
						end_scrape_date = scrape_frequency.minutes.ago
					end

					# logger.debug "comment_created_at #{comment_created_at.strftime("%I:%M %p, %b %e %Y")}"
					# logger.debug "end_scrape_date #{end_scrape_date.strftime("%I:%M %p, %b %e %Y")}"
					# logger.debug "date compare: (comment_created_at > end_scrape_date) => #{(comment_created_at > end_scrape_date)}"
					# logger.debug "@scrape_page.id => #{@scrape_page.id}"

					if (comment_created_at > end_scrape_date)
						# logger.debug "in the block if(comment_created_at < end_scrape_date)"
						this_comment = {}
						this_comment[:comment_id] 	 	 = comment["id"] 
						this_comment[:from_user_id]  = comment["from"]["id"]
						this_comment[:from_user_name] 	 = comment["from"]["name"]
						this_comment[:message]  = comment["message"]
						this_comment[:created_time]	 = comment_created_at
						this_comment[:scrape_page_id]	 = self.id

						@get_next_page = true

						@facebook_post = @scrape_page.facebook_posts.build(this_comment)
						# @comment_list << this_comment

						if @facebook_post.save
							@init_scrape_post_count +=1
							logger.debug "SAVED. @init_scrape_post_count = #{@init_scrape_post_count}"
						end

					else 
						logger.debug "!(comment_created_at < end_scrape_date) so setting get_next_page to false"
						@get_next_page = false
					end
				end # message_object each
			end # if not nil
		end # current page feed main block
		# logger.debug "@init_scrape_post_count: #{@init_scrape_post_count}"
		# logger.debug "@get_next_page : #{@get_next_page}"
		# @comment_list
	end


end