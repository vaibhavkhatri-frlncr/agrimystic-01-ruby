class Account < ApplicationRecord
	ActiveSupport.run_load_hooks(:account, self)
	self.table_name = :accounts

	include RansackSearchable

	has_secure_password
	before_validation :parse_full_phone_number
	before_validation :valid_phone_number
	before_validation :valid_password
	before_validation :valid_first_and_last_name
	before_create :generate_api_key

	has_one_attached :profile_pic

	validates :full_name, :first_name, :last_name, :full_phone_number, :address, :date_of_birth, presence: { message: 'Can\'t be blank' }
	validates :gender, inclusion: { in: %w(Male Female Trans-gender) }, allow_blank: true
  validates :password, presence: true, if: :password_changed?

	scope :active, -> { where(activated: true) }

	private

	def password_changed?
		password.present? || new_record?
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
			errors.add(:full_phone_number, 'Invalid or Unrecognized Phone Number')
		end
	end

	def valid_password
		return if password.blank?

		unless password.match?(/^(?=.*\d)(?=.*[a-z]).{8,}$/)
			errors.add(:password, 'Must be at least 8 characters long and include at least one lowercase letter and one digit')
		end
	end

	def valid_first_and_last_name
		return if first_name.blank? || last_name.blank?

    unless first_name.match?(/\A[a-zA-Z]+\z/)
      errors.add(:first_name, 'First name can only contain letters')
    end

		unless last_name.match?(/\A[a-zA-Z]+\z/)
			errors.add(:last_name, 'Last name can only contain letters')
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
