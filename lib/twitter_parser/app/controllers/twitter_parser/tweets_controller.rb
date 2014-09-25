require_dependency "twitter_parser/application_controller"

module TwitterParser
  class TweetsController < ApplicationController
    before_action :set_tweet, only: [:show, :edit, :update, :destroy]

    # GET /tweets
    def index
      @tweets = Tweet.all
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

    # POST /tweets
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
  end
end
