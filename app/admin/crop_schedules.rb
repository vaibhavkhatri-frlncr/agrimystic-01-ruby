ActiveAdmin.register CropSchedule do
  menu parent: 'Crop Management', priority: 1

  permit_params :crop, :heading, :crop_image, stages_attributes: [:id, :title, :_destroy, stage_details_attributes: [:id, :product_to_use, :benefits, :_destroy]]

  filter :crop
  filter :heading
  filter :created_at
  filter :updated_at

  form do |f|
    f.semantic_errors

    f.inputs 'Crop Schedule Details' do
      f.input :crop
      f.input :heading
      f.input :crop_image, as: :file, hint: 'Upload crop image'
    end

    f.inputs 'Stages' do
      f.has_many :stages, allow_destroy: true, new_record: true do |s|
        s.input :title
        s.has_many :stage_details, allow_destroy: true, new_record: true do |d|
          d.input :product_to_use
          d.input :benefits
        end
      end
    end

    f.actions
  end

  show do
    attributes_table do
      row :crop
      row :heading
      row :crop_image do |crop_schedule|
        crop_schedule.crop_image.attached? ? (image_tag url_for(crop_schedule.crop_image), size: '200x200') : 'No image attached'
      end
      row :created_at
      row :updated_at
    end

    panel 'Stages' do
      table_for crop_schedule.stages do
        column :title
        column 'Stage Details' do |stage|
          table_for stage.stage_details do
            column :product_to_use
            column :benefits
          end
        end
      end
    end
  end

  index do
    selectable_column
    id_column
    column :crop
    column :heading
    column :crop_image do |crop_schedule|
      crop_schedule.crop_image.attached? ? (image_tag url_for(crop_schedule.crop_image), size: '50x50') : 'No image attached'
    end

    actions
  end
end
