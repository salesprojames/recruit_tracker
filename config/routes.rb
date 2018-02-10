Rails.application.routes.draw do

  root 'recruits#index'

  resources :recruits do

  	resources :messages do
  		collection do
  			post 'reply'
  		end
  	end

    resources :tasks do
    	member do
    		get 'complete'
    	end
    end
  end

end
