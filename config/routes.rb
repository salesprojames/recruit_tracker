Rails.application.routes.draw do

  root 'recruits#index'

  resources :recruits do
    resources :tasks
  end

end
