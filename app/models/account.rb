class Account < ApplicationRecord
  attr_accessor :request_source

  ALLOWED_TYPES = %w[Farmer Trader].freeze

  has_secure_password

  has_one_attached :profile_image

  before_validation :titleize_account_fields
  before_validation :parse_full_phone_number
  before_validation :valid_phone_number
  before_validation :valid_password
  before_create     :generate_api_key

  validates :full_phone_number, :date_of_birth, :address, presence: true
  validates :gender,
            inclusion: { in: %w[Male Female Trans-gender] },
            allow_blank: true
  validates :pincode,
            format: { with: /\A[1-9][0-9]{5}\z/,
                      message: 'must be a valid 6-digit Indian PIN code' },
            allow_blank: true
  validate :profile_image_format
  validate :unique_verified_phone_number
  validate :validate_account_type
  validate :single_error_names

  scope :active, -> { where(activated: true) }

  private

  def validate_account_type
    if type.blank?
      errors.add(:type, "can't be blank")
    elsif !ALLOWED_TYPES.include?(type)
      errors.add(:type, 'must be Farmer or Trader')
    end
  end

  def single_error_names
    validations = {
      first_name: { min: 2, max: 50 },
      last_name:  { min: 2,  max: 50 },
      full_name:  { min: 4,  max: 60 }
    }

    validations.each do |attr, opts|
      value = send(attr).to_s.strip

      if value.blank?
        errors.add(attr, "can't be blank")
        next
      end

      if value.length < opts[:min]
        errors.add(attr, "is too short (minimum is #{opts[:min]} characters)")
        next
      end

      if value.length > opts[:max]
        errors.add(attr, "is too long (maximum is #{opts[:max]} characters)")
        next
      end

      unless value.match?(/\A[\p{L}\s'-]+\z/u)
        errors.add(attr, 'only allows letters and spaces')
        next
      end
    end
  end

  def unique_verified_phone_number
    return if full_phone_number.blank?

    query = Account.where(full_phone_number: full_phone_number, otp_verified: true)
    query = query.where.not(id: id) if request_source == :admin

    if query.exists?
      errors.add(:full_phone_number, 'has already been taken')
    end
  end

  def profile_image_format
    return unless profile_image.attached?

    allowed_types = %w[image/png image/jpg image/jpeg]

    unless profile_image.content_type.in?(allowed_types)
      errors.add(:profile_image, 'must be a valid image format (PNG, JPG, JPEG)')
    end
  end

  def titleize_account_fields
    self.first_name = titleize_string(first_name)
    self.last_name  = titleize_string(last_name)
    self.full_name  = titleize_string(full_name)
    self.address    = titleize_string(address)
    self.state      = titleize_string(state)
    self.district   = titleize_string(district)
    self.village    = titleize_string(village)
    self.gender     = titleize_string(gender)
  end

  def titleize_string(str)
    str.to_s.titleize if str.present?
  end

  def parse_full_phone_number
    phone              = Phonelib.parse(full_phone_number)
    self.full_phone_number = phone.sanitized
    self.country_code      = phone.country_code
    self.phone_number      = phone.raw_national
  end

  def valid_phone_number
    return if full_phone_number.blank?

    unless Phonelib.valid?(full_phone_number)
      errors.add(:full_phone_number, 'invalid or unrecognized phone number')
    end
  end

  def valid_password
    return if password.blank?

    unless password.match?(/\A(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_\-+=~`\[\]{}|\\:;"'<>,.?]).{8,}\z/)
      errors.add(:password,
                 'must be at least 8 characters long and include at least one uppercase letter, ' \
                 'one lowercase letter, one digit, and one special character')
    end
  end

  def generate_api_key
    loop do
      @token = SecureRandom.base64.tr('+/=', 'Qrt')
      break @token unless Account.exists?(unique_auth_id: @token)
    end
    self.unique_auth_id = @token
  end
end
