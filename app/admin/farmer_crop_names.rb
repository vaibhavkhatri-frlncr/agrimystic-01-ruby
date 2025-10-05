ActiveAdmin.register FarmerCropName do
  menu parent: 'Crop Master Data', priority: 1

  permit_params :name, :crop_image, farmer_crop_type_names_attributes: [:id, :name, :_destroy]

  config.sort_order = 'created_at_desc'

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

    f.inputs 'Farmer Crop Name Details' do
      f.input :name
      f.input :crop_image, as: :file, required: true, hint: 'Upload crop image'
    end

    f.inputs 'Farmer Crop Type Names' do
      f.has_many :farmer_crop_type_names, allow_destroy: true, new_record: true do |ct|
        ct.input :name
      end
    end

    f.actions
  end

  show do
    attributes_table do
      row :name
      row :crop_image do |farmer_crop_name|
        farmer_crop_name.crop_image.attached? ? (image_tag url_for(farmer_crop_name.crop_image), size: '200x200') : 'No image attached'
      end
      row :created_at
      row :updated_at
    end

    panel 'Farmer Crop Type Names' do
      table_for farmer_crop_name.farmer_crop_type_names.order(:created_at) do
        column('No.') { |ct| farmer_crop_name.farmer_crop_type_names.order(:created_at).index(ct) + 1 }
        column :name
        column :created_at
        column :updated_at
      end
    end
  end

  index do
    selectable_column

    column('No.', sortable: :created_at) do |crop|
      FarmerCropName.order(:created_at).pluck(:id).index(crop.id) + 1
    end

    column :name
    column :crop_image do |farmer_crop_name|
      farmer_crop_name.crop_image.attached? ? (image_tag url_for(farmer_crop_name.crop_image), size: '50x50') : 'No image attached'
    end
    column('Type Names Count') { |farmer_crop_name| farmer_crop_name.farmer_crop_type_names.count }

    actions
  end
end
