Rails.application.routes.draw do
	resources :research_articles, only: [:update]
  resources :research_topics, only: [:create, :update, :index, :destroy]
  resources :users, only: [:create, :edit, :update]
  get '/new_user', to: 'users#new', as: 'new_user'
  get '/my_account', to: 'users#show', as: 'my_account'

  get '/login', to: 'sessions#new', as: 'login'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: 'logout'
end
