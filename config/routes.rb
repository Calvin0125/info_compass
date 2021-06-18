Rails.application.routes.draw do
	resources :research_articles, only: [:update]
  resources :research_topics, only: [:create, :update, :index, :destroy]
  resources :users, only: [:new, :create, :show, :edit, :update]
  resources :sessions, only: [:create, :destroy]
  get '/login', to: 'sessions#new', as: 'login'
end
