class SmsAccount < Account
	validates :full_phone_number, uniqueness: true, presence: true
end
