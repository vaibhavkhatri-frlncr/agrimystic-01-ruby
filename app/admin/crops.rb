ActiveAdmin.register Crop do
  menu parent: 'Crop Knowledge Base', priority: 1

  permit_params :name, :crop_image

  filter :name
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

    f.inputs do
      f.input :name
      f.input :crop_image, as: :file, hint: 'Upload crop image'
    end
    f.actions
  end
  
  show do
    attributes_table do
      row :name
      row :crop_image do |crop|
        crop.crop_image.attached? ? (image_tag url_for(crop.crop_image), size: '200x200') : 'No image attached'
      end
      row :created_at
      row :updated_at
    end
  end

  index do
    selectable_column

    column('No.', sortable: :created_at) do |crop|
      Crop.order(:created_at).pluck(:id).index(crop.id) + 1
    end

    column :name
    column :crop_image do |crop|
      crop.crop_image.attached? ? (image_tag url_for(crop.crop_image), size: '50x50') : 'No image attached'
    end

    actions
  end
end
