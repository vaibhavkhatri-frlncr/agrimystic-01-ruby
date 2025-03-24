class AccountsController < ApplicationController
  before_action :validate_json_web_token, only: [:verify_signup_otp, :verify_otp, :reset_password, :show]

  def signup
    json_params = jsonapi_deserialize(params)
    phone = Phonelib.parse(json_params['full_phone_number']).sanitized
    account = Account.find_by(full_phone_number: phone)
  
    if account
      if account.activated?
        return render json: { errors: [{ account: 'Account already activated' }] }, status: :unprocessable_entity
      elsif !account.update(json_params.except('full_phone_number'))
        return render json: { errors: format_activerecord_errors(account.errors) }, status: :unprocessable_entity
      end

      return send_otp(phone, 'signup')
    end

    @account = Account.new(json_params)

    if @account.save
      return send_otp(@account.full_phone_number, 'signup')
    else
      render json: { errors: format_activerecord_errors(@account.errors) }, status: :unprocessable_entity
    end
  end

  def verify_signup_otp
    if validate_otp(params[:pin])
      account = Account.find_by(full_phone_number: @sms_otp.full_phone_number)
      return render json: { errors: [{ account: 'Account not found' }] }, status: :unprocessable_entity unless account

      account.update!(activated: true)
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
    phone ||= jsonapi_deserialize(params)['full_phone_number']
    purpose ||= jsonapi_deserialize(params)['purpose']

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
    account = Account.find(@token.id)

    unless account
      return render json: { errors: [{ account: 'Account not found' }] }, status: :not_found
    end

    if account.update(password: params[:new_password])
      render json: { message: 'Password reset successfully' }, status: :ok
    else
      render json: { errors: format_activerecord_errors(account.errors) }, status: :unprocessable_entity
    end
  end

  def show
    account = Account.find(@token.id)
    render json: AccountSerializer.new(account).serializable_hash, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { errors: [{ account: 'Account not found' }] }, status: :not_found
  end

  private

  def validate_otp(pin)
    begin
      @sms_otp = SmsOtp.find(@token.id)
    rescue ActiveRecord::RecordNotFound
      return false
    end

    return false if @sms_otp.valid_until < Time.current || @sms_otp.pin.to_s != pin.to_s

    @sms_otp.update!(activated: true)
    true
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
