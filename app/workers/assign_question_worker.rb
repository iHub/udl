class AssignQuestionWorker
	include Sidekiq::Worker
	sidekiq_options({ queue: :accounts })

	def perform(params)
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
end