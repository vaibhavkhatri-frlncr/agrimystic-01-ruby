class HelplineNumber < ApplicationRecord
  self.table_name = :helpline_numbers

  before_validation :valid_phone_number

  validates :phone_number, presence: true
  validates :region, presence: true, length: { minimum: 3, maximum: 100 }

  private

	def valid_phone_number
		return if phone_number.blank?

		unless Phonelib.valid?('+91'+phone_number.to_s)
			errors.add(:phone_number, 'invalid or unrecognized phone number')
		end
	end
end
