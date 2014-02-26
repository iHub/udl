ULog::Application.routes.draw do

  get "fb_comments/index"
  get "fb_comments/show"

  get "fb_posts/index"
  get "fb_posts/show"

  get "answers/index"
  get "answers/show"

  match "/queue" => DelayedJobWeb, :anchor => false, via: [:get, :post]

  resources :users
  resources :sessions, only: [:new, :create, :destroy]
  resources :app_settings
  
  resources :scrape_sessions do

    member do
      get :import
      get :retro
    end

    member do
      post :upload
      post :batch_retro
    end

    resources :scrape_pages do
      resources :fb_posts, only: [:index, :show]
    end

    resources :questions do
      resources :answers
    end

    # Session logs
    resources :answer_logs,       only: [:index, :show]
    resources :question_logs,     only: [:index, :show]
    resources :regular_scrape_logs, only: [:index, :show]
    resources :scrape_page_logs, only: [:index, :show]
    
  end    
  
  #login/logout routes
  match '/signup',  to: 'users#new',            via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'
  
  #static pages routes
  match '/help',    to: 'static_pages#help',    via: 'get'
  match '/about',   to: 'static_pages#about',   via: 'get'

  root  'static_pages#home'

end
