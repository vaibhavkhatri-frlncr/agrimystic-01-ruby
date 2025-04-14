class EmailOtp < ApplicationRecord
  include Wisper::Publisher

  self.table_name = :email_otps

  before_create :generate_pin_and_valid_date
  # after_create :send_pin_via_email

  validate :valid_email
  validates :email, presence: true

  def generate_pin_and_valid_date
    self.pin = 1234
    self.valid_until = Time.current + 5.minutes
  end

  def send_pin_via_email
		message = "Your Pin Number is #{pin}"
		txt = EmailOtpMailer.with(otp: self).otp_email.deliver
		txt.deliver
	end

  private

  def valid_email
    unless URI::MailTo::EMAIL_REGEXP.match?(email)
      errors.add(:email, "Invalid or Unrecognized Email")
    end
  end
end
