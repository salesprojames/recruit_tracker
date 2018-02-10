Rails.application.routes.draw do

  root 'recruits#index'

  resources :recruits do

  	resources :messages

    resources :tasks do
    	member do
    		get 'complete'
    	end
    end
  end

  post 'messages/reply'

end
