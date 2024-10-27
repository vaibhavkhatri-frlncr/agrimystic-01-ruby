class CropSchedulesController < ApplicationController
  before_action :validate_json_web_token

  def show
    crop = Crop.find_by(id: params[:id])

    if crop.nil?
      render json: { errors: [{ message: "Crop with id #{params[:id]} doesn't exist." }] }, status: :not_found
    else
      crop_schedule = crop.crop_schedule

      if crop_schedule.nil?
        render json: { data: {} }, status: :ok
      else
        render json: CropScheduleSerializer.new(crop_schedule), status: :ok
      end
    end
  end
end
