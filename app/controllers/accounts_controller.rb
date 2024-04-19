class AccountsController < ApplicationController
  def create
    case params[:data][:type]
    when 'sms_account'
      json_params = jsonapi_deserialize(params)
      account = SmsAccount.find_by(
        full_phone_number: json_params['full_phone_number'],
        activated: true
      )

      if account
        return render json: { errors: [{ account: 'Account already activated' }] }, status: :unprocessable_entity
      end

      @account = SmsAccount.new(json_params)

      if @account.save
        keys_to_delete = ['full_name', 'password', 'first_name', 'last_name', 'date_of_birth', 'address', 'state', 'district', 'village', 'pincode']
        sms_otp_params = json_params.except(*keys_to_delete)
        @sms_otp = SmsOtp.new(sms_otp_params)

        begin
          @sms_otp.save!
        rescue ActiveRecord::RecordInvalid => e
          @account.destroy
					return render json: {errors: format_activerecord_errors(@sms_otp.errors)},
				status: :unprocessable_entity
        end

        render json: SmsAccountSerializer.new(@account, meta: {
          token: encode(@sms_otp.id)
        }).serializable_hash, status: :created
      else
        render json: { errors: format_activerecord_errors(@account.errors) }, status: :unprocessable_entity
      end
    else
      render json: { errors: [{ account: 'Invalid Account Type' }] }, status: :unprocessable_entity
    end
  end

  private

  def encode(id)
    JsonWebToken.encode(id)
  end

  def format_activerecord_errors(errors)
    errors.messages.map { |attribute, error| { attribute => error } }
  end
end
