Rails.application.routes.draw do

  devise_for :users
  root 'recruits#index'
  post 'messages/reply'

  resources :recruits do
  	resources :messages
    resources :tasks do
    	member do
    		get 'complete'
    	end
    end
  end

  resources :general_messages, only: :index

end
