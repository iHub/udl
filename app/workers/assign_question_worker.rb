class AssignQuestionWorker
	include Sidekiq::Worker
	sidekiq_options({ queue: :accounts })

	def perform(*args)
		params = args[0]
		req_type = args[1]
		operation = args[2]
		user = args[3]

		case operation
		when "tag"
			tag_data(params, req_type, user)
		when "assign"
			assign_question_to_tagger(params)
		end		
	end

	def assign_question_to_tagger(params)
    disqus_records = params["question"]["disqus_num"]
    twitter_records = params["question"]["twitter_num"]

		@user_ids = params["question"]["user_ids"].reject(&:blank?)
		@scrape_session = Tagger::Question.find(params["question_id"]).scrape_session

    twitter_records.present? ? @tweets = @scrape_session.tweets.limit("#{twitter_records}") : 
    												   @tweets = @scrape_session.tweets.limit(20)
    disqus_records.present? ?  @disqus_forums = @scrape_session.disqus_forum_comments.limit("#{disqus_records}") : 
    										       @disqus_forums = @scrape_session.disqus_forum_comments.limit(20)


		if @user_ids.count == 1
			@user = User.find(@user_ids).first
			@user.tweet_ids = @tweets.map(&:id) 
      @user.disqus_forum_comment_ids = @disqus_forums.map(&:id)
      # AccountWorker.perform_async(@user.id, "notify")
		else
			@users = User.find(@user_ids)
			@x ||= 0
			@a = @tweets.count/@users.count
			@y ||= @a - 1
			@users.each do |user|
				@tagged_posts = @tweets[@x..@y]
				user.tweet_ids = @tagged_posts.map(&:id)
				@x = @y
				@y = @x + @y
        # AccountWorker.perform_async(user.id, "notify")
			end
		end
	end

	def tag_data(params, req_type, user)
		current_user = User.find(user)
		if req_type == "disqus"
      @forum = DisqusForumComment.find(params["tweet_id"])
      TweetAnswer.create(disqus_forum_comment: @forum, disqus_answer: @answer)
      current_user.tagged_disqus_posts << @forum
    elsif req_type == "tweet"
      @tweet = TwitterParser::Tweet.find(params["tweet_id"])
      TweetAnswer.create(tweet: @tweet, answer: @answer)
      current_user.tagged_posts << @tweet  
    end
	end

end