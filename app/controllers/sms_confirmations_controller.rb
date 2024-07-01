class SmsConfirmationsController < ApplicationController
  before_action :validate_json_web_token

  def create
    begin
      @sms_otp = SmsOtp.find(@token.id)
    rescue ActiveRecord::RecordNotFound => e
      return render json: { errors: [{ phone: 'Phone Number Not Found' }] }, status: :unprocessable_entity
    end

    if @sms_otp.valid_until < Time.current
      @sms_otp.destroy

      return render json: { errors: [{ pin: 'This Pin has expired, please request a new pin code.' }] }, status: :unauthorized
    end

    if @sms_otp.activated?
      return render json: ValidateAvailableSerializer.new(@sms_otp, meta: { message: 'Phone Number Already Activated' }).serializable_hash, status: :ok
    end

    if @sms_otp.pin.to_s == params['pin'].to_s
      @sms_otp.activated = true
      @sms_otp.save

      sms_account = SmsAccount.find_by(full_phone_number: @sms_otp.full_phone_number)
      if sms_account
        sms_account.update(activated: true)
      else
        return render json: { errors: [{ sms_account: 'SmsAccount not found for the given phone number' }] }, status: :unprocessable_entity
      end
      render json: ValidateAvailableSerializer.new(sms_account, meta: {
        message: 'Phone Number Confirmed Successfully',
        token: JsonWebToken.encode(sms_account.id)
      }).serializable_hash, status: :ok
    else
      render json: { errors: [{ pin: 'Invalid Pin for Phone Number' }] }, status: :unprocessable_entity
    end
  end
end
