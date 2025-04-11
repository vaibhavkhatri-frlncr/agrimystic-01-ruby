class AccountsController < ApplicationController
  before_action :validate_json_web_token, only: [:verify_signup_otp, :verify_otp, :reset_password, :show, :profile_details_update, :phone_update_otp_send, :phone_update_otp_verify]
  before_action :check_account_activated, only: [:verify_otp, :reset_password, :show, :profile_details_update, :phone_update_otp_send, :phone_update_otp_verify]

  def signup
    json_params = jsonapi_deserialize(params)
    phone = Phonelib.parse(json_params['full_phone_number']).sanitized
    account = Account.find_by(full_phone_number: phone)

    if account
      if account.otp_verified?
        return render json: { errors: [{ account: 'Account already registered' }] }, status: :unprocessable_entity
      elsif !account.update(json_params.except('full_phone_number'))
        return render json: { errors: format_activerecord_errors(account.errors) }, status: :unprocessable_entity
      end

      create_or_update_address(account, json_params)
      return send_otp(phone, 'signup')
    end

    @account = Account.new(json_params)

    if @account.save
      create_or_update_address(@account, json_params)
      return send_otp(@account.full_phone_number, 'signup')
    else
      render json: { errors: format_activerecord_errors(@account.errors) }, status: :unprocessable_entity
    end
  end

  def verify_signup_otp
    if validate_otp(params[:pin])
      account = Account.find_by(full_phone_number: @sms_otp.full_phone_number)

      return render json: { errors: [{ account: 'Account not found' }] }, status: :unprocessable_entity unless account

      account.update!(otp_verified: true)
      render json: { token: generate_account_token(account), message: 'OTP verified successfully' }, status: :ok
    else
      render json: { errors: [{ pin: 'Invalid or expired OTP' }] }, status: :unprocessable_entity
    end
  end

  def login
    account = OpenStruct.new(jsonapi_deserialize(params))
    
    output = AccountAdapter.new
    
    output.on(:account_not_found) do
      render json: {
        errors: [{ failed_login: 'Account not found, or not activated' }]
      }, status: :unprocessable_entity
    end
    
    output.on(:failed_login) do
      render json: {
        errors: [{ failed_login: 'Incorrect password' }]
      }, status: :unauthorized
    end
    
    output.on(:successful_login) do |account, token, refresh_token|
      render json: { meta: { token: token, refresh_token: refresh_token, id: account.id } }
    end
    
    output.login_account(account)
  end

  def send_otp(phone = nil, purpose = nil)
    phone ||= Phonelib.parse(jsonapi_deserialize(params)['full_phone_number']).sanitized
    purpose ||= jsonapi_deserialize(params)['purpose']

    if purpose == 'reset password'
      account = Account.find_by(full_phone_number: phone, otp_verified: true)

      if account.nil?
        return render json: { errors: [{ account: 'Account not found' }] }, status: :unprocessable_entity
      elsif !account.activated
        return render json: { errors: [{ account: 'Your account has been deactivated by the admin' }] }, status: :forbidden
      end
    end

    @sms_otp = SmsOtp.new(full_phone_number: phone)

    if @sms_otp.save
      render json: { token: generate_otp_token(@sms_otp, purpose), message: "OTP sent for #{purpose}" }, status: :created
    else
      render json: { errors: format_activerecord_errors(@sms_otp.errors) }, status: :unprocessable_entity
    end
  end

  def verify_otp
    if validate_otp(params[:pin])
      account = Account.find_by(full_phone_number: @sms_otp.full_phone_number)
      render json: { token: generate_account_token(account), message: 'OTP verified successfully' }, status: :ok
    else
      render json: { errors: [{ pin: 'Invalid or expired OTP' }] }, status: :unprocessable_entity
    end
  end

  def reset_password
    if current_user.update(password: params[:new_password])
      render json: { message: 'Password reset successfully' }, status: :ok
    else
      render json: { errors: format_activerecord_errors(current_user.errors) }, status: :unprocessable_entity
    end
  end

  def show
    render json: AccountSerializer.new(current_user).serializable_hash, status: :ok
  end

  def profile_details_update
    if current_user.update(profile_details_params)
      render json: AccountSerializer.new(current_user).serializable_hash, status: :ok
    else
      render json: { errors: format_activerecord_errors(current_user.errors) }, status: :unprocessable_entity
    end
  end

  def phone_update_otp_send
    new_phone = params[:full_phone_number]

    return render json: { errors: [{ phone: 'Phone number is required' }] }, status: :unprocessable_entity if new_phone.blank?

    parsed_new_phone = Phonelib.parse(new_phone).sanitized
    parsed_current_phone = current_user.full_phone_number

    if parsed_new_phone == parsed_current_phone
      return render json: { errors: [{ phone: 'New number must be different from current number' }] }, status: :unprocessable_entity
    end

    if Account.where(full_phone_number: parsed_new_phone, otp_verified: true).exists?
      return render json: { errors: [{ phone: 'This phone number is already taken' }] }, status: :unprocessable_entity
    end

    old_phone_otp = SmsOtp.new(full_phone_number: parsed_current_phone)
    new_phone_otp = SmsOtp.new(full_phone_number: parsed_new_phone)

    if old_phone_otp.save && new_phone_otp.save
      render json: {
        old_phone_token: generate_otp_token(old_phone_otp, 'change phone number'),
        new_phone_token: generate_otp_token(new_phone_otp, 'change phone number'),
        message: 'OTP sent to both current and new phone numbers'
      }, status: :created
    else
      errors = format_activerecord_errors(old_phone_otp.errors) + format_activerecord_errors(new_phone_otp.errors)
      render json: { errors: errors }, status: :unprocessable_entity
    end
  end

  def phone_update_otp_verify
    old_phone_pin = params[:old_phone_pin]
    new_phone_pin = params[:new_phone_pin]

    old_phone_token = request.headers[:HTTP_OLD_PHONE_TOKEN]
    new_phone_token = request.headers[:HTTP_NEW_PHONE_TOKEN]

    parsed_current_phone = current_user.full_phone_number

    old_phone_otp = validate_phone_otp(old_phone_token, old_phone_pin)
    new_phone_otp = validate_phone_otp(new_phone_token, new_phone_pin)

    errors = []
    errors << { old_phone_pin: 'Invalid or expired OTP' } unless old_phone_otp
    errors << { new_phone_pin: 'Invalid or expired OTP' } unless new_phone_otp

    return render json: { errors: errors }, status: :unauthorized if errors.any?

    if current_user.update(full_phone_number: new_phone_otp.full_phone_number)
      render json: { message: 'Phone number updated successfully' }, status: :ok
    else
      render json: { errors: format_activerecord_errors(current_user.errors) }, status: :unprocessable_entity
    end
  end

  private

  def create_or_update_address(account, params)
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

  def validate_otp(pin)
    begin
      @sms_otp = SmsOtp.find(@token.id)
    rescue ActiveRecord::RecordNotFound
      return false
    end

    return false if @sms_otp.valid_until < Time.current || @sms_otp.pin.to_s != pin.to_s

    @sms_otp.update!(activated: true)
    @sms_otp.destroy
    true
  end

  def validate_phone_otp(token, pin)
    token = JsonWebToken.decode(token)

    begin
      sms_otp = SmsOtp.find(token&.id)
    rescue ActiveRecord::RecordNotFound
      return false
    end

    return false if sms_otp.valid_until < Time.current || sms_otp.pin.to_s != pin.to_s

    sms_otp.update!(activated: true)
    # sms_otp.destroy
    sms_otp
  rescue *ERROR_CLASSES, ActiveRecord::RecordNotFound
    false
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
