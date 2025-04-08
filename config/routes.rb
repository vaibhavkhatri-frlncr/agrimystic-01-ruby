Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  post 'account/signup', to: 'accounts#signup'
  post 'account/verify_signup_otp', to: 'accounts#verify_signup_otp'
  post 'account/login', to: 'accounts#login'
  post 'account/send_otp', to: 'accounts#send_otp'
  post 'account/verify_otp', to: 'accounts#verify_otp'
  patch 'account/reset_password', to: 'accounts#reset_password'
  get 'account/details', to: 'accounts#show'

  resources :products, only: [:index, :show]
  get 'product/search', to: 'products#search'

  resources :categories, only: [:index]

  post 'cart/add_to_cart', to: 'carts#add_to_cart'
  post 'cart/remove_from_cart', to: 'carts#remove_from_cart'
  get 'cart/get_cart_products', to: 'carts#get_cart_products'

  resources :crops, only: [:index, :show]
  resources :crop_schedules, only: [:show]
  resources :identify_diseases, only: [:index, :show]
  resources :addresses, only: [:index, :show, :create, :update, :destroy]

  get 'helpline/numbers', to: 'helplines#index'
end
