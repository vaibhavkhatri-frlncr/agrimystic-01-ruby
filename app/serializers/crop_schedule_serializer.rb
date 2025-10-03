class CropScheduleSerializer < BaseSerializer
  attributes :crop, :heading, :created_at, :updated_at

  attribute :stages do |crop_schedule|
    crop_schedule.stages.map do |stage|
      stage.as_json.merge(
        stage_details: stage.stage_details.as_json
      )
    end
  end
end
