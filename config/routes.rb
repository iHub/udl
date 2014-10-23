require 'sidekiq/web'
ULog::Application.routes.draw do

  resources :disqus_forums

  mount TwitterParser::Engine => '/twitter_parser'
  mount Tagger::Engine => '/tagger'
  mount Sidekiq::Web => '/sidekiq'

  get "fb_comments/index"
  get "fb_comments/show"
  match "fb_comments/search", to: 'fb_comments#search', via: 'post'

  get "fb_posts/index"
  get "fb_posts/show"
  match "fb_posts/search", to: 'fb_posts#search', via: 'post'

  match "/queue" => DelayedJobWeb, :anchor => false, via: [:get, :post]

  resources :users
  resources :sessions, only: [:new, :create, :destroy]
  resources :app_settings #, only: [:new, :edit, :show, :index]
  
  resources :scrape_sessions do

    member do
      get :import
      get :retro
      get :tweets
    end

    member do
      post :upload
      post :batch_retro
    end

    resources :scrape_pages do
      resources :fb_posts, only: [:index, :show, :search]
    end

    resources :questions do
      resources :answers
    end

    # Session logs
    resources :answer_logs,       only: [:index, :show, :search]
    resources :question_logs,     only: [:index, :show, :search]
    resources :regular_scrape_logs, only: [:index, :show, :search]
    resources :scrape_page_logs, only: [:index, :show, :search]
    
  end    
  
  #login/out routes
  match '/signup',  to: 'users#new',            via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'
  
  #static pages routes
  match '/help',    to: 'static_pages#help',    via: 'get'
  match '/about',   to: 'static_pages#about',   via: 'get'

  root  'static_pages#home'

end
