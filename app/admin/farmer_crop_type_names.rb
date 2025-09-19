ActiveAdmin.register FarmerCropTypeName do
  menu parent: 'Crop Master Data', priority: 2

  permit_params :name, :farmer_crop_name_id

  config.sort_order = 'created_at_desc'

  filter :farmer_crop_name
  filter :name
  filter :created_at
  filter :updated_at

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

    f.inputs 'Crop Type Name Details' do
      f.input :farmer_crop_name, include_blank: 'Select crop'
      f.input :name, placeholder: 'Enter crop type name'
    end

    f.actions
  end

  show do
    attributes_table do
      row :farmer_crop_name
      row :name
      row :created_at
      row :updated_at
    end
  end

  index do
    selectable_column
    column('No.', sortable: :created_at) { |ct| FarmerCropTypeName.order(:created_at).pluck(:id).index(ct.id) + 1 }
    column :farmer_crop_name
    column :name
    actions
  end
end
