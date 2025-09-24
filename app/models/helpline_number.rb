class HelplineNumber < ApplicationRecord
  before_validation :titleize_region

  validates :phone_number, presence: true, format: { with: /\A[7-9]\d{9}\z/, message: 'must be a valid 10-digit Indian mobile number starting with 7, 8, or 9' }, uniqueness: { case_sensitive: false }
  validates :region, presence: true, length: { minimum: 3, maximum: 100 }, uniqueness: { case_sensitive: false }

  private

  def titleize_region
    self.region = region.to_s.titleize if region.present?
  end
end
