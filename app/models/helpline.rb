class Helpline < ApplicationRecord
  self.table_name = :helplines

  before_validation :valid_phone_number

  validates :phone_number, presence: true
  validate :single_record_only

  private

  def single_record_only
    if Helpline.exists? && new_record?
      errors.add(:base, 'Only one helpline number is allowed.')
    end
  end

	def valid_phone_number
		return if phone_number.blank?

		unless Phonelib.valid?('+91'+phone_number.to_s)
			errors.add(:phone_number, 'Invalid or Unrecognized Phone Number')
		end
	end
end
