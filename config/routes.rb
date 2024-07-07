Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  post 'account/accounts', to: 'accounts#create'
  post 'account/send_otps', to: 'send_otps#create'
  post 'account/sms_otp_confirmations', to: 'sms_confirmations#create'
  post 'account/login', to: 'logins#create'

  resources :products, only: [:index, :show]
  get 'product/search', to: 'products#search'

  resources :categories, only: [:index]

  post 'cart/add_to_cart', to: 'carts#add_to_cart'
  post 'cart/remove_from_cart', to: 'carts#remove_from_cart'
  get 'cart/get_cart_products', to: 'carts#get_cart_products'

  resources :crop_schedules, only: [:index, :show]
  resources :identify_diseases, only: [:index, :show]
end
