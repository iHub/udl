module Tagger
  class Question < ActiveRecord::Base
    belongs_to :scrape_session
    has_many :answers

    validates_presence_of :scrape_session
    validates_uniqueness_of :content
    
    attr_accessor :tagger_ids, :user_ids
    accepts_nested_attributes_for :answers, allow_destroy: true

    def to_s
    	content
    end

    class << self
    	def assign_records_to_user(params)
    		@user_ids = params[:question][:user_ids].reject(&:blank?)
    		@forum = find(params[:question_id]).forum
    		@posts = @forum.posts

    		if @user_ids.count == 1
    			@user = User.find(@user_ids).first
    			@user.post_ids = @posts.map(&:id)            
    		else
    			@users = User.find(@user_ids)
    			@x ||= 0
    			@a = @posts.count/@users.count
    			@y ||= @a - 1
    			@users.each do |user|
    				@tagged_posts = @posts[@x..@y]
    				user.post_ids = @tagged_posts.map(&:id)
    				@x = @y
    				@y = @x+@y
    			end
    		end

    	end

    	def question_forum(params)
    		find(params[:question_id])
    	end
    end
  end
end
