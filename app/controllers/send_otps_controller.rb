class SendOtpsController < ApplicationController
	def create
		json_params = jsonapi_deserialize(params)
		account = SmsAccount.find_by(
			full_phone_number: json_params['full_phone_number'],
			activated: true
		)

		unless account.nil?
			return render json: {errors: [{
				account: 'Account already activated'
			}]}, status: :unprocessable_entity
		end

		keys_to_delete = ['password', 'first_name', 'last_name', 'date_of_birth', 'address', 'state', 'district', 'village', 'pincode']
		sms_otp_params = json_params.except(*keys_to_delete)
		@sms_otp = SmsOtp.new(sms_otp_params)

		if @sms_otp.save
			render json: SmsOtpSerializer.new(@sms_otp, meta: {
				token: JsonWebToken.encode(@sms_otp.id)
			}).serializable_hash, status: :created
		else
			render json: {errors: format_activerecord_errors(@sms_otp.errors)},
				status: :unprocessable_entity
		end
	end

	private

	def format_activerecord_errors(errors)
		result = []
		errors.each do |attribute, error|
			result << {attribute => error}
		end
		result
	end
end
