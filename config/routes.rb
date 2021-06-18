Rails.application.routes.draw do
	resources :research_articles, only: [:update]
  resources :research_topics, only: [:create, :update, :index, :destroy]
  resources :users, only: [:create, :show, :edit, :update]
  get '/new_user', to: 'users#new', as: 'new_user'
  resources :sessions, only: [:create, :destroy]
  get '/login', to: 'sessions#new', as: 'login'
end
