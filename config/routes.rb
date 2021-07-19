Rails.application.routes.draw do
  get '/', to: 'pages#index', as: 'home'

	resources :research_articles, only: [:update]
  get '/research', to: 'research_topics#index', as: 'research_topics'
  resources :research_topics, only: [:create, :update, :destroy]
  resources :search_terms, only: [:create, :destroy]

  resources :users, only: [:create, :edit, :update]
  get '/new_user', to: 'users#new', as: 'new_user'
  get '/my_account', to: 'users#show', as: 'my_account'

  get '/login', to: 'sessions#new', as: 'login'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: 'logout'

  # routes under construction
  get '/news', to: 'news_topics#index', as: 'news_topics'
  get '/music', to: 'music_artists#index', as: 'music_artists'
  get '/books', to: 'authors#index', as: 'authors'
end
