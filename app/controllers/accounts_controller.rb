class AccountsController < ApplicationController
  before_action [:validate_json_web_token, :check_account_activated], only: [:reset_password, :details, :details_update, :send_phone_update_otp, :verify_phone_update_otp, :send_email_update_otp, :verify_email_update_otp]

  ALLOWED_STI = %w[Farmer Trader].freeze

  def signup
    json_params = jsonapi_deserialize(params)
    phone = Phonelib.parse(json_params['full_phone_number']).sanitized

    klass = if json_params['type'].present? && ALLOWED_STI.include?(json_params['type'].to_s)
              json_params['type'].constantize
            else
              Account
            end

    existing_account = klass.find_by(full_phone_number: phone, otp_verified: false)
    existing_account.destroy if existing_account.present?

    account = klass.new
    account.assign_attributes(json_params)

    if account.save
      sync_farmer_address(account, json_params) if account.is_a?(Farmer)

      SmsOtp.where(full_phone_number: account.full_phone_number, purpose: 'signup', activated: false).destroy_all

      sms_otp = SmsOtp.new(full_phone_number: account.full_phone_number, purpose: 'signup')
      if sms_otp.save
        render json: {
          token: generate_otp_token(sms_otp, 'signup'),
          message: "OTP sent for signup."
        }, status: :created
      else
        render json: { errors: format_activerecord_errors(sms_otp.errors) }, status: :unprocessable_entity
      end
    else
      render json: { errors: format_activerecord_errors(account.errors) }, status: :unprocessable_entity
    end
  end

  def verify_signup_otp
    begin
      token = request.headers[:token] || params[:token]
      otp_id = JsonWebToken.decode(token).id
      sms_otp = SmsOtp.find_by(id: otp_id, purpose: 'signup')
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      return render json: {
        errors: [{ otp: "No OTP request found for this phone number." }]
      }, status: :unprocessable_entity
    end

    if sms_otp.nil?
      return render json: {
        errors: [{ otp: "No OTP request found for this phone number." }]
      }, status: :unprocessable_entity
    end

    if sms_otp.valid_until < Time.current
      return render json: {
        errors: [{ otp: "OTP has expired. Please request a new one." }]
      }, status: :unprocessable_entity
    end

    if sms_otp.pin.to_s != params[:otp].to_s
      return render json: {
        errors: [{ otp: "Invalid OTP. Please try again." }]
      }, status: :unprocessable_entity
    end

    account = Account.find_by(full_phone_number: sms_otp.full_phone_number)
    if account.nil?
      return render json: {
        errors: [{ account: "Account not found." }]
      }, status: :unprocessable_entity
    end

    if account.otp_verified?
      return render json: {
        errors: [{ account: "Account is already verified." }]
      }, status: :unprocessable_entity
    end

    account.update!(otp_verified: true)

    sms_otp.destroy

    render json: {
      message: "OTP verified successfully. You can now login your account."
    }, status: :ok
  end

  def login
    account = OpenStruct.new(jsonapi_deserialize(params))

    output = AccountAdapter.new

    output.on(:account_not_found) do
      render json: {
        errors: [{ account: "Account not found." }]
      }, status: :unprocessable_entity
    end

    output.on(:account_deactivated) do
      render json: {
        errors: [{ account: "Your account has been deactivated by the admin." }]
      }, status: :forbidden
    end

    output.on(:failed_login) do
      render json: {
        errors: [{ password: "Incorrect password." }]
      }, status: :unauthorized
    end

    output.on(:successful_login) do |account, token, refresh_token|
      render json: {
        meta: {
          token: token,
          refresh_token: refresh_token,
          id: account.id,
          type: account.type
        }
      }, status: :ok
    end

    output.login_account(account)
  end

  def send_forgot_password_otp
    json_params = jsonapi_deserialize(params)
    phone = Phonelib.parse(json_params['full_phone_number']).sanitized
    account_type = json_params['type']

    account = Account.find_by(full_phone_number: phone, otp_verified: true, type: account_type)

    if account.nil?
      return render json: {
        errors: [{ account: "Account not found." }]
      }, status: :unprocessable_entity
    end

    unless account.activated?
      return render json: {
        errors: [{ account: "Your account has been deactivated by the admin." }]
      }, status: :forbidden
    end

    SmsOtp.where(full_phone_number: account.full_phone_number, purpose: 'reset_password', activated: false).destroy_all

    sms_otp = SmsOtp.new(full_phone_number: account.full_phone_number, purpose: 'reset_password')

    if sms_otp.save
      render json: {
        token: generate_otp_token(sms_otp, 'reset_password'),
        message: "OTP sent for password reset."
      }, status: :created
    else
      render json: { errors: format_activerecord_errors(sms_otp.errors) }, status: :unprocessable_entity
    end
  end

  def verify_forgot_password_otp
    begin
      token = request.headers[:token] || params[:token]
      otp_id = JsonWebToken.decode(token).id
      sms_otp = SmsOtp.find_by(id: otp_id, purpose: 'reset_password')
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      return render json: {
        errors: [{ otp: "No OTP request found for this phone number." }]
      }, status: :unprocessable_entity
    end

    if sms_otp.nil?
      return render json: {
        errors: [{ otp: "No OTP request found for this phone number." }]
      }, status: :unprocessable_entity
    end

    if sms_otp.valid_until < Time.current
      return render json: {
        errors: [{ otp: "OTP has expired. Please request a new one." }]
      }, status: :unprocessable_entity
    end

    if sms_otp.pin.to_s != params[:otp].to_s
      return render json: {
        errors: [{ otp: "Invalid OTP. Please try again." }]
      }, status: :unprocessable_entity
    end

    account = Account.find_by(full_phone_number: sms_otp.full_phone_number)
    if account.nil?
      return render json: {
        errors: [{ account: "Account not found." }]
      }, status: :unprocessable_entity
    end

    unless account.activated?
      return render json: {
        errors: [{ account: "Your account has been deactivated by the admin." }]
      }, status: :forbidden
    end

    sms_otp.update!(activated: true)
    sms_otp.destroy

    render json: {
      token: generate_account_token(account),
      message: "OTP verified successfully. You can now reset your password."
    }, status: :ok
  end

  def reset_password
    current_user.request_source = :admin

    if current_user.authenticate(params[:password])
      return render json: {
        errors: [{ password: "New password cannot be the same as the current password." }]
      }, status: :unprocessable_entity
    end

    if current_user.update(password: params[:password])
      render json: {
        message: 'Password reset successfully.'
      }, status: :ok
    else
      render json: { errors: format_activerecord_errors(current_user.errors) }, status: :unprocessable_entity
    end
  end

  def details
    render json: AccountSerializer.new(current_user).serializable_hash, status: :ok
  end

  def details_update
    current_user.request_source = :admin

    if current_user.update(profile_details_params)
      render json: {
        message: 'Account details updated successfully.'
      }, status: :ok
    else
      render json: { errors: format_activerecord_errors(current_user.errors) }, status: :unprocessable_entity
    end
  end

  def send_phone_update_otp
    new_phone = params[:full_phone_number]

    return render json: {
      errors: [{ full_phone_number: 'Phone number is required.' }]
    }, status: :unprocessable_entity if new_phone.blank?

    parsed_new_phone = Phonelib.parse(new_phone).sanitized
    parsed_current_phone = current_user.full_phone_number

    if parsed_new_phone == parsed_current_phone
      return render json: {
        errors: [{ full_phone_number: 'New phone number must be different from current phone number.' }]
      }, status: :unprocessable_entity
    end

    if Account.where(full_phone_number: parsed_new_phone, otp_verified: true).exists?
      return render json: {
        errors: [{ full_phone_number: 'This phone number is already taken.' }]
      }, status: :unprocessable_entity
    end

    SmsOtp.where(full_phone_number: [parsed_current_phone, parsed_new_phone], purpose: 'update_phone_number', activated: false).destroy_all

    old_phone_otp = SmsOtp.new(full_phone_number: parsed_current_phone, purpose: 'update_phone_number')
    new_phone_otp = SmsOtp.new(full_phone_number: parsed_new_phone, purpose: 'update_phone_number')

    if old_phone_otp.save && new_phone_otp.save
      render json: {
        old_phone_token: generate_otp_token(old_phone_otp, 'update_phone_number'),
        new_phone_token: generate_otp_token(new_phone_otp, 'update_phone_number'),
        message: 'OTP sent to both current and new phone numbers.'
      }, status: :created
    else
      errors = format_activerecord_errors(old_phone_otp.errors) + format_activerecord_errors(new_phone_otp.errors)
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def verify_phone_update_otp
    old_phone_otp = params[:old_phone_otp]
    new_phone_otp = params[:new_phone_otp]

    old_phone_token = request.headers[:HTTP_OLD_PHONE_TOKEN]
    new_phone_token = request.headers[:HTTP_NEW_PHONE_TOKEN]

    errors = []

    old_phone_otp = fetch_and_verify_sms_otp(old_phone_token, 'update_phone_number', old_phone_otp)
    new_phone_otp = fetch_and_verify_sms_otp(new_phone_token, 'update_phone_number', new_phone_otp)

    errors << { old_phone_otp: 'Invalid or expired OTP.' } unless old_phone_otp
    errors << { new_phone_otp: 'Invalid or expired OTP.' } unless new_phone_otp

    return render json: { errors: errors }, status: :unauthorized if errors.any?

    if current_user.update(full_phone_number: new_phone_otp.full_phone_number)
      old_phone_otp.destroy
      new_phone_otp.destroy
      render json: {
        message: 'Phone number updated successfully.'
      }, status: :ok
    else
      render json: { errors: format_activerecord_errors(current_user.errors) }, status: :unprocessable_entity
    end
  end

  def send_email_update_otp
    new_email = params[:email]

    return render json: {
      errors: [{ email: 'Email is required.' }]
    }, status: :unprocessable_entity if new_email.blank?

    current_email = current_user.email

    if Account.where(email: new_email.downcase, otp_verified: true).where.not(id: current_user.id).exists?
      return render json: {
        errors: [{ email: 'This email is already taken.' }]
      }, status: :unprocessable_entity
    end

    # CASE 1: No email yet → only verify new email
    if current_email.nil?
      new_email_otp = EmailOtp.new(email: new_email, purpose: 'update_email')
      if new_email_otp.save
        render json: {
          new_email_token: generate_otp_token(new_email_otp, 'update_email'),
          message: 'OTP sent to email address.'
        }, status: :created
      else
        render json: { errors: format_activerecord_errors(new_email_otp.errors) }, status: :unprocessable_entity
      end
      return
    end

    # CASE 2: Changing existing email → verify both old & new
    if new_email.downcase == current_email.downcase
      return render json: {
        errors: [{ email: 'New email must be different from current email.' }]
      }, status: :unprocessable_entity
    end

    EmailOtp.where(email: [current_email, new_email], purpose: 'update_email', activated: false).destroy_all

    old_email_otp = EmailOtp.new(email: current_email, purpose: 'update_email')
    new_email_otp = EmailOtp.new(email: new_email, purpose: 'update_email')

    if old_email_otp.save && new_email_otp.save
      render json: {
        old_email_token: generate_otp_token(old_email_otp, 'update_email'),
        new_email_token: generate_otp_token(new_email_otp, 'update_email'),
        message: 'OTP sent to both current and new email addresses.'
      }, status: :created
    else
      errors = format_activerecord_errors(old_email_otp.errors) + format_activerecord_errors(new_email_otp.errors)
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def verify_email_update_otp
    current_user.request_source = :admin

    new_email_otp = params[:new_email_otp]
    old_email_otp = params[:old_email_otp]

    new_email_token = request.headers[:HTTP_NEW_EMAIL_TOKEN]
    old_email_token = request.headers[:HTTP_OLD_EMAIL_TOKEN]

    current_email = current_user.email
    errors = []

    if current_email.nil?
      new_email_otp = fetch_and_verify_email_otp(new_email_token, 'update_email', new_email_otp)
      errors << { new_email_otp: 'Invalid or expired OTP.' } unless new_email_otp
      return render json: { errors: errors }, status: :unauthorized if errors.any?

      if current_user.update(email: new_email_otp.email)
        new_email_otp.destroy
        render json: {
          message: 'Email updated successfully.'
        }, status: :ok
      else
        render json: { errors: format_activerecord_errors(current_user.errors) }, status: :unprocessable_entity
      end
      return
    end

    old_email_otp = fetch_and_verify_email_otp(old_email_token, 'update_email', old_email_otp)
    new_email_otp = fetch_and_verify_email_otp(new_email_token, 'update_email', new_email_otp)

    errors << { old_email_otp: 'Invalid or expired OTP.' } unless old_email_otp
    errors << { new_email_otp: 'Invalid or expired OTP.' } unless new_email_otp
    return render json: { errors: errors }, status: :unauthorized if errors.any?

    if current_user.update(email: new_email_otp.email)
      old_email_otp.destroy
      new_email_otp.destroy
      render json: {
        message: 'Email updated successfully.'
      }, status: :ok
    else
      render json: { errors: format_activerecord_errors(current_user.errors) }, status: :unprocessable_entity
    end
  end

  private

  def profile_details_params
    params.require(:account).permit(
      :first_name,
      :last_name,
      :profile_image
    )
  end

  def sync_farmer_address(account, params)
    return unless account.is_a?(Farmer)

    address_attrs = {
      name: params['full_name'],
      mobile: Phonelib.parse(params['full_phone_number']).sanitized&.last(10),
      address: params['address'],
      pincode: params['pincode'],
      state: params['state'],
      district: params['district'],
      address_type: :home,
      default_address: true
    }

    if account.addresses.exists?(address_type: :home)
      address = account.addresses.find_by(address_type: :home)
      address.update(address_attrs)
    else
      account.addresses.create(address_attrs)
    end
  end

  def fetch_and_verify_sms_otp(token, purpose, otp_code)
    return false if token.blank? || otp_code.blank?

    begin
      otp_id = JsonWebToken.decode(token).id
      sms_otp = SmsOtp.find_by(id: otp_id, purpose: purpose)
      return false unless sms_otp
      return false if sms_otp.valid_until < Time.current
      return false unless sms_otp.pin.to_s == otp_code.to_s

      sms_otp.update!(activated: true)
      sms_otp
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      false
    end
  end

  def fetch_and_verify_email_otp(token, purpose, otp_code)
    return false if token.blank? || otp_code.blank?

    begin
      otp_id = JsonWebToken.decode(token).id
      email_otp = EmailOtp.find_by(id: otp_id, purpose: purpose)
      return false unless email_otp
      return false if email_otp.valid_until < Time.current
      return false unless email_otp.pin.to_s == otp_code.to_s

      email_otp.update!(activated: true)
      email_otp
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      false
    end
  end

  def generate_otp_token(otp, type)
    JsonWebToken.encode(otp.id, 5.minutes.from_now, token_type: type)
  end

  def generate_account_token(account)
    JsonWebToken.encode(account.id, 5.minutes.from_now)
  end

  def format_activerecord_errors(errors)
    errors.messages.map { |attribute, error| { attribute => error } }
  end
end
