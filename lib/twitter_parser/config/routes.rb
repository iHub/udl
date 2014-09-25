TwitterParser::Engine.routes.draw do
  
  resources :tweets do
  	get :tag
  	put :tag	
  end

	root to: 'tweets#index'
  resources :terms
  resources :accounts, only: [:new, :create, :index, :destroy]
  match '/tagged_posts', to: 'tweets#tagged_posts', via: :get, as: :tagged_posts
  match '/all_tweets', to: 'tweets#all_tweets', via: :get, as: :all_tweets
end
