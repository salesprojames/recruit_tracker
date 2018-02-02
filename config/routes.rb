Rails.application.routes.draw do

  root 'recruits#index'

  resources :recruits do
    resources :tasks do
    	member do
    		get 'complete'
    	end
    end
  end

end
