Tagger::Engine.routes.draw do
  resources :questions do
  	get :assign
  	put :assign
  end
  root to: 'questions#index'
end
