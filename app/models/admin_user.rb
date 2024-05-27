class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  include RansackSearchable

  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, 
         :recoverable, :rememberable, :validatable
end
