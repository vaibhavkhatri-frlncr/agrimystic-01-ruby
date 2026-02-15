class HelplineNumbersController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated

  def index
    page     = params[:page] || 1
    per_page = params[:per_page] || 10

    helpline_numbers = HelplineNumber.order(created_at: :desc).page(page).per(per_page)

    if helpline_numbers.present?
      render json: {
        helpline_numbers: HelplineNumberSerializer.new(helpline_numbers),
        meta: {
          current_page: helpline_numbers.current_page,
          next_page: helpline_numbers.next_page,
          prev_page: helpline_numbers.prev_page,
          total_pages: helpline_numbers.total_pages,
          total_count: helpline_numbers.total_count
        }
      }, status: :ok
    else
      render json: {
        errors: [{ message: 'No helpline numbers found.' }]
      }, status: :not_found
    end
  end
end
