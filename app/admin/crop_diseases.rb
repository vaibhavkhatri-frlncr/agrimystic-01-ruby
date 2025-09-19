ActiveAdmin.register CropDisease do
  menu parent: 'Crop Knowledge Base', priority: 3

  permit_params :crop_id, :disease_name, :disease_cause, :solution, :products_recommended, :disease_image

  filter :crop
  filter :disease_name
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
      f.input :crop, include_blank: 'select crop'
      f.input :disease_name
      f.input :disease_cause, as: :text, input_html: { style: 'width: 50%; height: 100px; resize: vertical;' }
      f.input :solution, as: :text, input_html: { style: 'width: 50%; height: 100px; resize: vertical;' }
      f.input :products_recommended
      f.input :disease_image, as: :file, hint: f.object.disease_image.attached? ? image_tag(url_for(f.object.disease_image), size: '100x100') : 'Upload disease image'
    end

    f.actions
  end

  show do
    attributes_table do
      row :crop
      row :disease_name
      row :disease_cause
      row :solution
      row :products_recommended
      row :disease_image do |crop_disease|
        crop_disease.disease_image.attached? ? (image_tag url_for(crop_disease.disease_image), size: '200x200') : 'No image attached'
      end
      row :created_at
      row :updated_at
    end
  end

  index do
    selectable_column

    column('No.', sortable: :created_at) do |disease|
      CropDisease.order(:created_at).pluck(:id).index(disease.id) + 1
    end

    column :crop
    column :disease_name
    column :disease_image do |crop_disease|
      crop_disease.disease_image.attached? ? (image_tag url_for(crop_disease.disease_image), size: '50x50') : 'No image attached'
    end

    actions
  end
end
