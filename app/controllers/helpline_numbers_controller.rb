class HelplineNumbersController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated

  def index
    helplines = HelplineNumber.all

    if helplines.present?
      render json: HelplineNumberSerializer.new(helplines), status: :ok
    else
      render json: { errors: { message: 'No helpline numbers found.' } }, status: :not_found
    end
  end
end
