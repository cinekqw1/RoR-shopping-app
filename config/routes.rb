Rails.application.routes.draw do
  
  devise_for :users
  resources :items do
  	member do
  		patch :complete
  	end
  end
  root 'items#index'

  match '/api' => 'api#login', via: :post ,format: :json
  match '/api/items' => 'api#items', via: :post ,format: :json
  match '/api/logout' => 'api#logout', via: :post ,format: :json
end
