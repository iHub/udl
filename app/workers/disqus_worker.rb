class DisqusWorker
	include Sidekiq::Worker
	include Sidetiq::Schedulable
	sidekiq_options( { queue: :disqus } )

	def perform(id)
		fetch_disqus_comments(id)
	end

	def fetch_disqus_comments(id)
		forum = DisqusForum.find(id)
		comments = DisqusApi.v3.posts.list(forum: "#{forum.forum_name}") if forum
		DisqusForumComment.create_self(comments)	
	end

	def continous_comments_fetch
		forums = DisqusForum.all.map(&:forum_name)
		forums.each do |forum|
			comments = DisqusApi.v3.posts.list(forum: "#{forum.forum_name}")
			DisqusForumComment.create_self(comments)
		end
	end

end