Rails.application.routes.draw do
	resources :research_articles, only: [:update]
  resources :research_topics, only: [:create, :update, :index, :destroy]
  resources :users, only: [:new, :create, :show, :edit, :update]
  resources :sessions, only: [:new, :create, :destroy]
end
