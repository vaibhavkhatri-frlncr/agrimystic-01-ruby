ActiveAdmin.register Product do
  menu parent: 'Product Management', priority: 2

  permit_params :category_id, :product_image, :name, :code, :manufacturer, :dosage, :features, :description,
                images: [], product_variants_attributes: [:id, :size, :price, :quantity, :_destroy]

  config.sort_order = 'created_at_desc'

  remove_filter :product_image_attachment, :product_image_blob
  filter :category
  filter :name
  filter :code
  filter :manufacturer
  filter :dosage
  filter :features
  filter :total_price, label: 'Total Inventory Value'
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

    f.inputs 'Product Details' do
      f.input :category, include_blank: 'select category'
      f.input :product_image, as: :file, hint: (
        if f.object.persisted? && f.object.product_image.attached?
          image_tag(url_for(f.object.product_image), size: '100x100')
        else
          'Upload product image'
        end
      )
      f.input :name
      f.input :code
      f.input :manufacturer
      f.input :dosage
      f.input :features
      f.input :description, as: :text, input_html: { style: 'width: 50%; height: 100px; resize: vertical;' }
      f.input :images, as: :file, input_html: { multiple: true }, hint: (
        if f.object.persisted? && f.object.images.attached?
          f.object.images.map { |img| image_tag(url_for(img), size: '100x100', style: 'margin-right: 10px;') }.join.html_safe
        else
          'Upload product images'
        end
      )
    end

    f.inputs 'Product Variants' do
      f.has_many :product_variants, heading: 'Product Variants', new_record: 'Add Variant' do |v|
        v.input :size
        v.input :price, hint: 'Enter price in ₹'
        v.input :quantity
        v.input :_destroy, as: :boolean, label: 'Remove Variant' unless v.object.new_record?
      end
    end

    f.actions
  end

  show do
    attributes_table do
      row :product_image do |product|
        product.product_image.attached? ? (image_tag url_for(product.product_image), size: '200x200') : 'No image attached'
      end
      row :category
      row :name
      row :code
      row :manufacturer
      row :dosage
      row :features
      row :description
      row 'Total Inventory Value' do |product|
        "₹#{product.total_price}"
      end
      row :images do |product|
        if product.images.attached?
          product.images.map.with_index(1) do |img, index|
            image_tag url_for(img), size: '100x100', title: "Image #{index}"
          end.join.html_safe
        else
          'No images attached'
        end
      end
      row :created_at
      row :updated_at
    end

    panel 'Product Variants' do
      table_for product.product_variants.order(:created_at) do
        column('No.') { |variant| product.product_variants.order(:created_at).index(variant) + 1 }
        column :size
        column('Price per unit') { |variant| "₹#{variant.price}" }
        column :quantity
        column('Total Value') { |variant| "₹#{variant.price * variant.quantity}" }
        column :created_at
        column :updated_at
      end
    end
  end

  index do
    selectable_column

    column('No.', sortable: :created_at) do |product|
      Product.order(:created_at).pluck(:id).index(product.id) + 1
    end

    column :product_image do |product|
      product.product_image.attached? ? (image_tag url_for(product.product_image), width: '50') : 'No image attached'
    end
    column :category
    column :name
    column :code
    column :manufacturer
    column('Total Inventory Value') { |product| "₹#{product.total_price}" }

    actions

    table_for Product do
      column('Total Products') { Product.count }
      column('Total Amount') { "₹#{Product.sum(:total_price)}" }
    end
  end

  controller do
    def update
      if params[:product][:images].all?(&:blank?) && resource.images.attached?
        params[:product].delete(:images)
      end
      super
    end
  end
end
