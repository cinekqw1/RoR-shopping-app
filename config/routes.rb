Rails.application.routes.draw do
  
  resources :categories
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
  match '/api/createitem' => 'api#create_item', via: :post ,format: :json
  match '/api/destroy' => 'api#destroy', via: :post ,format: :json
  match '/api/complete' => 'api#complete', via: :post ,format: :json
end
