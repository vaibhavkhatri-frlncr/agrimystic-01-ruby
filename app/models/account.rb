class Account < ApplicationRecord
	self.table_name = :accounts

	has_secure_password
	before_validation :titleize_account_fields
	before_validation :parse_full_phone_number
	before_validation :valid_phone_number
	before_validation :valid_password
	before_validation :valid_first_and_last_name
	before_create :generate_api_key

	has_one_attached :profile_image
	has_one :cart, dependent: :destroy
	has_many :cart_products, through: :cart
	has_many :products, through: :cart_products
	has_many :addresses, dependent: :destroy
	has_many :orders, dependent: :destroy

	validates :type, presence: true, inclusion: { in: %w[Farmer Trader] }
	validates :full_name, :first_name, :last_name, :full_phone_number, :address, :date_of_birth, presence: true
	validates :gender, inclusion: { in: %w(Male Female Trans-gender) }, allow_blank: true
	validates :pincode, format: { with: /\A[1-9][0-9]{5}\z/, message: 'must be a valid 6-digit Indian PIN code' }, allow_blank: true
	validates :password, presence: true, if: :password_changed?
	validate :valid_profile_image_format, if: -> { profile_image.attached? }

	scope :active, -> { where(activated: true) }

	private

	def valid_profile_image_format
		allowed_types = %w[
			image/png
			image/jpg
			image/jpeg
			image/gif
			image/bmp
			image/webp
			image/tiff
			image/x-icon
			image/vnd.microsoft.icon
			image/heif
			image/heic
			image/svg+xml
		]

		unless profile_image.content_type.in?(allowed_types)
			errors.add(:profile_image, 'must be a valid image format (PNG, JPG, JPEG, GIF, BMP, WEBP, TIFF, ICO, HEIF, HEIC, SVG)')
		end
	end

	def password_changed?
		password.present? || new_record?
	end

	def titleize_account_fields
    self.first_name = titleize_string(first_name)
    self.last_name = titleize_string(last_name)
    self.full_name = titleize_string(full_name)
    self.address = titleize_string(address)
    self.state = titleize_string(state)
    self.district = titleize_string(district)
    self.village = titleize_string(village)
    self.gender = titleize_string(gender)
  end

	def titleize_string(str)
		str.to_s.titleize if str.present?
	end

	def parse_full_phone_number
		phone = Phonelib.parse(full_phone_number)
		self.full_phone_number = phone.sanitized
		self.country_code = phone.country_code
		self.phone_number = phone.raw_national
	end

	def valid_phone_number
		return if full_phone_number.blank?

		unless Phonelib.valid?(full_phone_number)
			errors.add(:full_phone_number, 'invalid or unrecognized phone number')
		end
	end

	def valid_password
		return if password.blank?

		unless password.match?(/^(?=.*\d)(?=.*[a-z]).{8,}$/)
			errors.add(:password, 'must be at least 8 characters long and include at least one lowercase letter and one digit')
		end
	end

	def valid_first_and_last_name
		return if first_name.blank? || last_name.blank?

    unless first_name.match?(/\A[a-zA-Z]+\z/)
      errors.add(:first_name, 'first name can only contain letters')
    end

		unless last_name.match?(/\A[a-zA-Z]+\z/)
			errors.add(:last_name, 'last name can only contain letters')
		end
	end

	def generate_api_key
		loop do
			@token = SecureRandom.base64.tr("+/=", "Qrt")
			break @token unless Account.exists?(unique_auth_id: @token)
		end
		self.unique_auth_id = @token
	end
end
