class HelplineNumbersController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated

  def index
    page     = params[:page] || 1
    per_page = params[:per_page] || 10
    search   = params[:search]

    helpline_numbers = HelplineNumber.order(created_at: :desc)

    if search.present?
      helpline_numbers = helpline_numbers.where(
        "CAST(phone_number AS TEXT) LIKE :search
        OR LOWER(region) LIKE :search",
        search: "%#{search.downcase}%"
      )
    end

    helpline_numbers = helpline_numbers.page(page).per(per_page)

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
      error_message = "No helpline numbers found"

      error_message += " matching '#{search}'" if search.present?
      error_message += "."

      render json: {
        errors: [{ message: error_message }]
      }, status: :not_found
    end
  end
end
