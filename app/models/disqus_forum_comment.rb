class DisqusForumComment < ActiveRecord::Base
	belongs_to :disqus_forum
	belongs_to :scrape_session
	belongs_to :user

	validates :disqus_forum, presence: true
	validates :forum_id, uniqueness: true, allow_blank: true
	

	#TaggingDisqusComments
	#----------------------------------------------------------------------------
	has_many :tweet_answers
	has_many :answers, through: :tweet_answers, class_name: "Tagger::Answer", source: :answer


	# has_many :tweet_answers
	# has_many :answers, :through => :tweet_answers, class_name: "Tagger::Answer"
	has_many :tagger_posts, :class_name => "Tagger::TaggerPost"
	has_many :taggers, :through => :tagger_posts, source: :user

	def self.create_self(comments)
		comments[:response].each do |comment|
			forum = DisqusForum.where("forum_name @@ :q", q: "#{comment[:forum]}").first
			
			return false unless forum
			forum.disqus_forum_comments.create(
				forum_name: comment[:forum] ,points: comment[:points], parent: comment[:parent], is_approved: comment[:isApproved], author_about: comment[:author][:about], 
				author_username: comment[:author][:username], author_name: comment[:author][:name], author_url: comment[:author][:url],
				author_is_following: comment[:author][:isFollowing], author_is_follwed_by: comment[:author][:isFollwedBy],
				author_profile_url: comment[:author][:profileUrl], author_reputation: comment[:author][:reputation], forum_num_reports:comment[:numReports],
				author_location: comment[:author][:location], author_id: comment[:author][:id], author_disliked: comment[:disliked], author_raw_message: comment[:raw_message],
				text: comment[:message], author_created_at: comment[:createdAt], forum_id: comment[:id], forum_thread: comment[:thread], 
				forum_likes: comment[:likes], forum_is_edited: comment[:isEdited], forum_message: comment[:message], forum_is_spam: comment[:isSpam],
				forum_is_highlighted:comment[:isHighlighted], forum_user_score: comment[:userScore]
			)
		end
	end

end
