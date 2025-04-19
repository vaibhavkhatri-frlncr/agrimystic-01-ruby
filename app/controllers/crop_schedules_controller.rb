class CropSchedulesController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated
  before_action :load_crop_schedule

  def show
    return if @crop.nil? || @crop_schedule.nil?

    render json: CropScheduleSerializer.new(@crop_schedule), status: :ok
  end

  private

  def load_crop_schedule
    @crop = Crop.find_by(id: params[:id])

    if @crop.nil?
      render json: { errors: [{ message: "Crop with id #{params[:id]} doesn't exist." }] }, status: :not_found
      return
    end

    @crop_schedule = @crop.crop_schedule

    if @crop_schedule.nil?
      render json: { errors: [{ message: "Crop schedule for crop id #{params[:id]} doesn't exist." }] }, status: :not_found
    end
  end
end
