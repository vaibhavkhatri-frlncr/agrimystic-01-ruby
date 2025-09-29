class ApplicationController < ActionController::Base
  include JsonWebTokenValidation
	include JSONAPI::Deserialization

	protect_from_forgery with: :exception
	skip_before_action :verify_authenticity_token

	rescue_from ActiveRecord::RecordNotFound, :with => :not_found

	private

	def not_found
		render :json => {'errors' => ['Record not found']}, :status => :not_found
	end

	def current_user
		return if @token.blank?

		@current_user ||= Account.find_by(id: @token.id)

		unless @current_user
			render json: { errors: [{ account: 'Account not found.' }] }, status: :not_found and return
		end

		@current_user
	end

	def check_account_activated
		return unless current_user

		unless current_user.activated
			render json: { errors: [{ account: 'Your account has been deactivated by the admin.' }] }, status: :forbidden
		end
	end
end
