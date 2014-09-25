TwitterParser::Engine.routes.draw do
  resources :tweets

	root to: 'tweets#index'
  resources :terms
  resources :accounts, only: [:new, :create, :index, :destroy]

end
