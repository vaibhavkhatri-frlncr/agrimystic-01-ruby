class HelplineNumbersController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated

  def index
    helpline_numbers = HelplineNumber.all

    if helpline_numbers.present?
      render json: HelplineNumberSerializer.new(helpline_numbers), status: :ok
    else
      render json: { errors: [{ message: 'No helpline numbers found.' }] }, status: :not_found
    end
  end
end
