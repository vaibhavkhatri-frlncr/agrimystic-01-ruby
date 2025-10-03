Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root to: redirect('/admin')

  resources :accounts, only: [] do
    collection do
      post 'signup'
      post 'verify_signup_otp'
      post 'login'
      post 'send_forgot_password_otp'
      post 'verify_forgot_password_otp'
      patch 'reset_password'
      get 'details'
      put 'details_update'
      post 'send_phone_update_otp'
      put 'verify_phone_update_otp'
      post 'send_email_update_otp'
      put 'verify_email_update_otp'
    end
  end

  resources :helpline_numbers, only: [:index]

  resources :crops, only: [:index, :show]

  resources :crop_schedules, only: [:show]

  resources :crop_diseases, only: [:index, :show]

  resources :categories, only: [:index]

  resources :products, only: [:index, :show]

  resources :addresses, only: [:index, :show, :create, :update, :destroy] do
    collection do
      get 'google_maps_api_key', to: 'addresses#google_maps_api_key'
    end
  end

  resources :farmer_crop_names, only: [:index, :show]
  resources :farmer_crops, only: [:index, :show, :create, :update, :destroy]
  get 'farmer_crop/current_farmer_crops', to: 'farmer_crops#current_farmer_crops'

  post 'cart/add_to_cart', to: 'carts#add_to_cart'
  post 'cart/remove_from_cart', to: 'carts#remove_from_cart'
  get 'cart/get_cart_products', to: 'carts#get_cart_products'

  resources :orders, only: [:index, :create]
  put 'orders/:id/cancel', to: 'orders#cancel'
  post 'orders/:id/process_payment', to: 'orders#process_payment'
  get 'order/razorpay_api_key', to: 'orders#razorpay_api_key'
  post 'orders/:id/payment_verification', to: 'orders#payment_verification'

end
