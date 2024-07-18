class HelplinesController < ApplicationController
  before_action :validate_json_web_token

  def show
    helpline = Helpline.first

    if helpline
      render json: { data: { phone_number: helpline.phone_number } }, status: :ok
    else
      render json: { errors: { message: 'Helpline number not found.' } }, status: :not_found
    end
  end
end
