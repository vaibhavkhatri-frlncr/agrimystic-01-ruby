class CropSchedulesController < ApplicationController
  before_action :validate_json_web_token
  before_action :load_crop_schedule, only: [:show]

  def index
    crop_schedules = CropSchedule.all
    render json: CropScheduleSerializer.new(crop_schedules), status: :ok
  end

  def show
    return if @crop_schedule.nil?
    render json: CropScheduleSerializer.new(@crop_schedule), status: :ok
  end

  private

  def load_crop_schedule
    @crop_schedule = CropSchedule.find_by(id: params[:id])

    if @crop_schedule.nil?
      render json: { errors: [{ message: "Crop schedule with id #{params[:id]} doesn\'t exists." }] }, status: :not_found
    end
  end
end
