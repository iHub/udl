require_dependency "twitter_parser/application_controller"

module TwitterParser
  class TweetsController < ApplicationController
    before_action :set_tweet, only: [:show, :edit, :update, :destroy]
    before_action :current_user, only: [:tag]

    # GET /tweets
    def all_tweets
      @tweet_count = TwitterParser::Tweet.count
      @tweet_count = Tweet.count
      @tweets = Tweet.all.limit(30)
    end


    def index
      @untagged_tweets = (current_user.tweets - current_user.tagged_posts)
      @tweets = @untagged_tweets.paginate(:per_page => 10, :page => params[:page])    
    end

    def tagged_posts
      @tweets = current_user.tagged_posts.paginate(:per_page => 10, :page => params[:page])
    
      respond_to do |format|
        format.html
        format.csv { render text: @tweets.to_csv(@tweets) }
      end
    end



    # GET /tweets/1
    def show
    end

    # GET /tweets/new
    def new
      @tweet = Tweet.new
    end

    # GET /tweets/1/edit
    def edit
    end

    def tag
      @id = request.url.split("?ref=").last
      @answer = Tagger::Answer.find(@id) if @id
      return request.referrer unless @answer.present?

      @tweet = Tweet.find(params[:tweet_id])
      TweetAnswer.create(tweet: @tweet, answer: @answer)
      @current_user.tagged_posts << @tweet
      redirect_to (request.referrer || :back), notice: "Tagged successfully"
    end

    # Tweet /tweets
    def create
      @tweet = Tweet.new(tweet_params)

      if @tweet.save
        redirect_to @tweet, notice: 'Tweet was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /tweets/1
    def update
      if @tweet.update(tweet_params)
        redirect_to @tweet, notice: 'Tweet was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /tweets/1
    def destroy
      @tweet.destroy
      redirect_to tweets_url, notice: 'Tweet was successfully destroyed.'
    end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_tweet
      @tweet = Tweet.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def tweet_params
      params.require(:tweet).permit(:tweet_id, :text, :tweet_user)
    end

    def current_user
      remember_token = User.encrypt(cookies[:remember_token])
      @current_user ||= User.find_by(remember_token: remember_token)
    end
  end
end
