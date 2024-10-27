class CropScheduleSerializer < BaseSerializer
  attributes :crop, :heading

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
