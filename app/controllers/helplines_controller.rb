class HelplinesController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated

  def index
    helplines = Helpline.all

    if helplines.any?
      render json: HelplineSerializer.new(helplines), status: :ok
    else
      render json: { errors: { message: 'Helpline numbers are currently unavailable.' } }, status: :not_found
    end
  end
end
