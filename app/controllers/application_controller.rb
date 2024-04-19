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
		@current_user ||= Account.find(@token.id)
	end

	def check_account_activated
		account = Account.find_by(id: current_user.id)
		unless account.activated
			render json: {error: {
				message: 'Account has been not activated'
			}}, status: :unprocessable_entity
		end
	end
end
