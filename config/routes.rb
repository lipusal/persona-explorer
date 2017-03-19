Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'home#index'

  resources :personas, only: [:index, :show]

  get '/advanced_search', to: 'personas#advanced_search'
end
