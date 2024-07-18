class Helpline < ApplicationRecord
  self.table_name = :helplines

  validates :phone_number, presence: true
  validate :single_record_only

  private

  def single_record_only
    if Helpline.exists? && new_record?
      errors.add(:base, 'Only one helpline number is allowed.')
    end
  end
end
