Rails.application.routes.draw do
	devise_for :users, controllers: {registrations: 'users/registrations'}

	root 'maps#index'
	resources :users
	resources :maps
	resources :comments
  	get 'homes/index'
  	post 'maps/ajax', to: 'maps#ajax'
  	get 'maps/ajax', to: 'maps#ajax'
  	get '/ajax' => 'maps#ajax', as: :ajax
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
