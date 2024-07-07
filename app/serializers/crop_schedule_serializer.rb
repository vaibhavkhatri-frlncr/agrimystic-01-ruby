class CropScheduleSerializer < BaseSerializer
  attributes :crop, :heading

  attribute :crop_image do |crop_schedule|
    base_url + Rails.application.routes.url_helpers.rails_blob_path(crop_schedule.crop_image, only_path: true) if crop_schedule.crop_image.attached?
  end

  attribute :stages do |crop_schedule|
    crop_schedule.stages.order(:created_at).map do |stage|
      {
        title: stage.title,
        stage_details: stage.stage_details.order(:created_at).map do |stage_detail|
          {
            product_to_use: stage_detail.product_to_use,
            benefits: stage_detail.benefits
          }
        end
      }
    end
  end

  attributes :created_at, :updated_at
end
