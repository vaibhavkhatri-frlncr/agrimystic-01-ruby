ActiveAdmin.register CropSchedule do
  menu parent: 'Crop Management', priority: 2

  permit_params :crop_id, :heading, stages_attributes: [:id, :title, :_destroy, stage_details_attributes: [:id, :product_to_use, :benefits, :_destroy]]

  filter :crop
  filter :heading
  filter :created_at
  filter :updated_at

  config.sort_order = 'created_at_desc'

  form do |f|
    if f.object.errors[:base].any?
      div style: 'background-color: #ffe6e6; border: 1px solid #ff4d4d; padding: 10px; margin-bottom: 20px; color: #d8000c; font-weight: bold;' do
        ul style: 'padding-left: 20px; margin: 0;' do
          f.object.errors[:base].each do |msg|
            li "• #{msg}"
          end
        end
      end
    end

    f.inputs 'Crop Schedule Details' do
      f.input :crop, include_blank: 'select crop'
      f.input :heading
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

    column('No.', sortable: :created_at) do |schedule|
      CropSchedule.order(:created_at).pluck(:id).index(schedule.id) + 1
    end

    column :crop
    column :heading

    actions
  end
end
