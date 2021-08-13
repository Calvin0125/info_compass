Rails.application.routes.draw do
  get '/', to: 'pages#index', as: 'home'

	resources :research_articles, only: [:update]
  get '/research', to: 'research_topics#index', as: 'research_topics'
  resources :research_topics, only: [:create, :update, :destroy]
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

  # Error routes
  get "/404", to: "errors#error_404"
  get "/422", to: "errors#error_422"
  get "/500", to: "errors#error_500"

  # routes under construction
  get '/news', to: 'news_topics#index', as: 'news_topics'
  get '/music', to: 'music_artists#index', as: 'music_artists'
  get '/books', to: 'authors#index', as: 'authors'
end
