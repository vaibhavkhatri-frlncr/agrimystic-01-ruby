Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  post 'account/accounts', to: 'accounts#create'
  post 'account/send_otps', to: 'send_otps#create'
  post 'account/sms_otp_confirmations', to: 'sms_confirmations#create'
  post 'account/login', to: 'logins#create'

  resources :products, only: [:index, :show]
end
