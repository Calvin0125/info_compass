Rails.application.routes.draw do
  get '/', to: 'pages#index', as: 'home'

	resources :articles, only: [:update, :create]
  get '/research', to: 'topics#research_index', as: 'research'
  get '/news', to: 'topics#news_index', as: 'news'
  resources :topics, only: [:create, :update, :destroy]
  resources :search_terms, only: [:create, :destroy]

  resources :users, only: [:create, :update]
  get '/new_account', to: 'users#new', as: 'new_account'
  get '/my_account', to: 'users#show', as: 'my_account'
  get '/edit_account', to: 'users#edit', as: 'edit_account'
  get '/forgot_password', to: 'users#forgot_password', as: 'forgot_password'
  post '/forgot_password', to: 'users#forgot_password'
  get '/reset_password/:token', to: 'users#reset_password', as: 'reset_password'
  post '/reset_password', to: 'users#reset_password'
  get '/reset_password_confirmation', to: 'users#reset_password_confirmation', as: 'reset_password_confirmation'

  get '/login', to: 'sessions#new', as: 'login'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: 'logout'
  get 'active', to: 'sessions#active'
  get 'timeout', to: 'sessions#timeout'

  # Error routes
  get "/404", to: "errors#error_404"
  get "/422", to: "errors#error_422"
  get "/500", to: "errors#error_500"
end
