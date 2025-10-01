class Address < ApplicationRecord
  belongs_to :farmer, class_name: "Farmer"
  has_many :orders

  before_validation :titleize_address_fields

  enum address_type: { home: 0, office: 1, other: 2 }

  validates :name, :mobile, :pincode, :state, :address, :district, presence: true
  validate :validate_address_name
  validate :validate_mobile_format
  validates :pincode,
            format: { with: /\A[1-9][0-9]{5}\z/,
                      message: 'must be a valid 6-digit Indian PIN code' },
            allow_blank: true
  validates :address_type, presence: { message: "must be selected" }

  private

  def titleize_address_fields
    self.name     = titleize_string(name)
    self.address  = titleize_string(address)
    self.state    = titleize_string(state)
    self.district = titleize_string(district)
  end

  def titleize_string(str)
    str.to_s.split.map(&:capitalize).join(" ") if str.present?
  end

  def validate_address_name
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

  def validate_mobile_format
    return if mobile.blank?

    unless mobile.to_s.match?(/\A[7-9]\d{9}\z/)
      errors.add(:mobile, "must be a valid 10-digit Indian mobile number starting with 7, 8, or 9")
    end
  end
end
