class Category < ApplicationRecord
  has_many :products, dependent: :destroy

  before_validation :titleize_name

  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validate :validate_category_name

  private

  def titleize_name
    self.name = name.to_s.titleize if name.present?
  end

  def validate_category_name
    value = name.to_s.strip

    return if value.blank?

    if value.length < 2
      errors.add(:name, "is too short (minimum is 2 characters)")
      return
    end

    if value.length > 50
      errors.add(:name, "is too long (maximum is 50 characters)")
      return
    end

    unless value.match?(/\A[a-zA-Z\s]+\z/)
      errors.add(:name, 'only allows letters and spaces')
    end
  end
end
