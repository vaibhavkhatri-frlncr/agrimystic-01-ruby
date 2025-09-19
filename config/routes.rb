Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root to: redirect('/admin')

  post 'account/signup', to: 'accounts#signup'
  post 'account/verify_signup_otp', to: 'accounts#verify_signup_otp'
  post 'account/login', to: 'accounts#login'
  post 'account/send_otp', to: 'accounts#send_otp'
  post 'account/verify_otp', to: 'accounts#verify_otp'
  patch 'account/reset_password', to: 'accounts#reset_password'
  get 'account/details', to: 'accounts#show'
  put 'account/details_update', to: 'accounts#profile_details_update'
  post 'account/phone_update_otp_send', to: 'accounts#phone_update_otp_send'
  put 'account/phone_update_otp_verify', to: 'accounts#phone_update_otp_verify'
  post 'account/email_update_otp_send', to: 'accounts#email_update_otp_send'
  put 'account/email_update_otp_verify', to: 'accounts#email_update_otp_verify'

  resources :products, only: [:index, :show]
  get 'product/search', to: 'products#search'

  resources :categories, only: [:index]

  post 'cart/add_to_cart', to: 'carts#add_to_cart'
  post 'cart/remove_from_cart', to: 'carts#remove_from_cart'
  get 'cart/get_cart_products', to: 'carts#get_cart_products'

  resources :crops, only: [:index, :show]
  resources :crop_schedules, only: [:show]
  resources :crop_diseases, only: [:index, :show]
  resources :addresses, only: [:index, :show, :create, :update, :destroy]
  get 'address/google_maps_api_key', to: 'addresses#google_maps_api_key'

  resources :helpline_numbers, only: [:index]
  resources :orders, only: [:index, :create]
  put 'orders/:id/cancel', to: 'orders#cancel'
  post 'orders/:id/process_payment', to: 'orders#process_payment'
  get 'order/razorpay_api_key', to: 'orders#razorpay_api_key'
  post 'orders/:id/payment_verification', to: 'orders#payment_verification'

  resources :farmer_crop_names, only: [:index, :show]
  resources :farmer_crops, only: [:index, :show, :create, :update, :destroy]
  get 'farmer_crop/current_farmer_crops', to: 'farmer_crops#current_farmer_crops'
end
