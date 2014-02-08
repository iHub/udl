ULog::Application.routes.draw do

  # get "answer_logs/index"
  # get "answer_logs/show"
  # get "question_logs/index"
  # get "question_logs/show"
  # get "deleted_page_logs/index"
  # get "deleted_page_logs/show"
  # get "new_page_logs/index"
  # get "new_page_logs/show"
  # get "init_scrape_logs/index"
  # get "init_scrape_logs/show"
  # get "regular_scrape_logs/index"
  # get "regular_scrape_logs/show"
  get "fb_comments/index"
  get "fb_comments/show"
  match "fb_comments/search", to: 'fb_comments#search', via: 'post'

  get "fb_posts/index"
  get "fb_posts/show"
  match "fb_posts/search", to: 'fb_posts#search', via: 'post'

  get "test_posts/index"
  get "test_posts/show"
  get "test_posts/comments"
  get "test_posts/comments_fql"
  get "test_posts/test"

  get "facebook_posts/index"
  get "facebook_posts/show"
  match "facebook_posts/search", to: 'facebook_posts#search', via: 'post'

  match "/queue" => DelayedJobWeb, :anchor => false, via: [:get, :post]

  # get "app_settings/index"
  # get "app_settings/edit"

  get "csv_import/import"
  get "logs/index"
  
  resources :users
  resources :sessions, only: [:new, :create, :destroy]
  resources :app_settings, only: [:new, :edit]
  
  resources :scrape_sessions do

    member do
      get :import
    end

    member do
      post :upload
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

    resources :init_scrape_logs,    only: [:index, :show, :search]
    resources :regular_scrape_logs, only: [:index, :show, :search]

    resources :deleted_page_logs, only: [:index, :show, :search]
    resources :new_page_logs,     only: [:index, :show, :search]
    
  end    
  
  #login/out routes
  match '/signup',  to: 'users#new',            via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'
  
  #static pages routes
  match '/help',    to: 'static_pages#help',    via: 'get'
  match '/about',   to: 'static_pages#about',   via: 'get'

  # app settings
  # match '/app_settings',       to: 'app_settings#index',   via: 'get'
  # match '/edit_app_settings',  to: 'app_settings#edit',    via: 'get'

  root  'static_pages#home'

end
