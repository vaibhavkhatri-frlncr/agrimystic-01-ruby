ActiveAdmin.register FarmerCrop do
  menu parent: 'Crop Master Data', priority: 3

  actions :all, except: [:new, :create]

  permit_params :farmer_crop_name_id, :farmer_crop_type_name_id, :variety, :description,
                :moisture_content, :quantity, :price, :contact_number,
                farmer_crop_images: []

  config.sort_order = 'created_at_desc'

  remove_filter :farmer_crop_images_attachment, :farmer_crop_images_blob
  filter :farmer_crop_name, as: :select, collection: -> { FarmerCropName.all.pluck(:name, :id) }
  filter :farmer_crop_type_name, as: :select, collection: -> { FarmerCropTypeName.all.pluck(:name, :id) }
  filter :variety
  filter :description
  filter :moisture_content
  filter :quantity
  filter :price
  filter :contact_number
  filter :contact_number, as: :string, label: "Contact Number"
  filter :farmer_first_name, as: :string
  filter :farmer_last_name, as: :string
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

    f.inputs 'Farmer Crop Details' do
      f.input :farmer_crop_name, label: "Name", include_blank: 'Select name'
      f.input :farmer_crop_type_name, label: "Type", include_blank: 'Select type'
      f.input :variety
      f.input :description, as: :text, input_html: { style: 'width: 50%; height: 100px; resize: vertical;' }
      f.input :moisture_content
      f.input :quantity
      f.input :price
      f.input :contact_number
      f.input :farmer_crop_images, as: :file, required: true, input_html: { multiple: true }, hint: 'Upload crop images'
    end

    f.actions
  end

  show do
    attributes_table do
      row("Crop") do |crop|
        crop.farmer_crop_name&.name
      end
      row("Type") do |crop|
        crop.farmer_crop_type_name&.name
      end
      row :variety
      row :description
      row :moisture_content
      row :quantity
      row :price
      row :contact_number
      row('Farmer') { |crop| "#{crop.farmer.first_name} #{crop.farmer.last_name}" }
      row('Address') { |crop| crop.farmer.address }
      row('District') { |crop| crop.farmer.district }
      row('State') { |crop| crop.farmer.state }
      row('Village') { |crop| crop.farmer.village }
      row('Pincode') { |crop| crop.farmer.pincode }
      row("Images") do |crop|
        if crop.farmer_crop_images.attached?
          crop.farmer_crop_images.map.with_index(1) do |img, index|
            image_tag url_for(img), size: '100x100', title: "Image #{index}"
          end.join.html_safe
        else
          'No images attached'
        end
      end
      row :created_at
      row :updated_at
    end

    panel "Crop Reviews" do
      if resource.reviews.any?
        table_for resource.reviews.order(created_at: :desc) do
          column('No.') do |review|
            resource.reviews.order(created_at: :desc).pluck(:id).index(review.id) + 1
          end
          column("Trader") do |review|
            link_to review.trader.full_name, admin_trader_path(review.trader)
          end
          column("Phone") { |review| review.trader.phone_number if review.trader.present? }
          column("Address") { |review| review.trader.address if review.trader.present? }
          column("Rating") { |review| review.rating }
          column("Review") { |review| review.review }
          column("Created At") { |review| review.created_at }
        end
      else
        div do
          span "No reviews associated with this crop."
        end
      end
    end
  end

  index do
    selectable_column

    column('No.', sortable: :created_at) do |crop|
      FarmerCrop.order(:created_at).pluck(:id).index(crop.id) + 1
    end
    column('Crop') do |crop|
      link_to crop.farmer_crop_name.name, admin_farmer_crop_path(crop)
    end
    column('Type') do |crop|
      link_to crop.farmer_crop_type_name.name, admin_farmer_crop_path(crop)
    end
    column :variety
    column :description
    column :moisture_content
    column :quantity
    column :price
    column :contact_number
    column('Farmer') do |crop|
      link_to "#{crop.farmer.first_name} #{crop.farmer.last_name}", admin_farmer_path(crop.farmer)
    end

    actions
  end

  controller do
    def update
      if params[:farmer_crop][:farmer_crop_images].all?(&:blank?) && resource.farmer_crop_images.attached?
        params[:farmer_crop].delete(:farmer_crop_images)
      end
      super
    end
  end
end
