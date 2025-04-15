class SmsOtp < ApplicationRecord
	self.table_name = :sms_otps

	include Wisper::Publisher

	before_validation :parse_full_phone_number

	before_create :generate_pin_and_valid_date
	# after_create :send_pin_via_sms

	validate :valid_phone_number
	validates :full_phone_number, presence: true

	def generate_pin_and_valid_date
		self.pin = 1234
		self.valid_until = Time.current + 5.minutes
	end

	def send_pin_via_sms
		message = generate_otp_message
		txt = SendSms.new("+#{full_phone_number}", message)
		txt.call
	end

	private

	def parse_full_phone_number
		@phone = Phonelib.parse(full_phone_number)
		self.full_phone_number = @phone.sanitized
	end

	def valid_phone_number
		unless Phonelib.valid?(full_phone_number)
			errors.add(:full_phone_number, 'Invalid or Unrecognized Phone Number')
		end
	end

	def generate_otp_message
		base_message = case purpose
			when 'signup'
				"Welcome to Agrimystic! Your sign-up OTP is #{pin}."
			when 'reset password'
				"Use OTP #{pin} to reset your Agrimystic password."
			when 'change phone number'
				"Use OTP #{pin} to confirm your phone number change on Agrimystic."
			else
				"Your Agrimystic OTP is #{pin}."
			end

		"#{base_message} It is valid for 5 minutes."
	end
end
