class Enquiry < ApplicationRecord
  belongs_to :trader, class_name: 'Trader'
  belongs_to :farmer_crop

  before_validation :clean_message

  validates :message, presence: true, length: { minimum: 10, maximum: 1000 }

  private

  def clean_message
    return if message.blank?

    self.message = message.strip
    self.message = message.gsub(/\s+/, " ")
  end
end
