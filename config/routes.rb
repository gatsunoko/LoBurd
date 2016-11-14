Rails.application.routes.draw do
  	devise_for :users
	root 'maps#index'
	resources :users
	resources :maps
	resources :comments do
		collection do
			post :upload_process
		end
		# member do
		# 	post :upload_process
		# end
	end
  	get 'homes/index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
