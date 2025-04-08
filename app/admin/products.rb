ActiveAdmin.register Product do
  menu parent: 'Product Management', priority: 2

  permit_params :category_id, :product_image, :name, :code, :manufacturer, :dosage, :features, :description, images: [], product_variants_attributes: [:id, :size, :price, :quantity, :_destroy]

  remove_filter :product_image_attachment, :product_image_blob
  filter :category
  filter :name
  filter :code
  filter :manufacturer
  filter :dosage
  filter :features
  filter :total_price
  filter :created_at
  filter :updated_at

  form do |f|
    f.semantic_errors

    f.inputs 'Product Details' do
      f.input :category, include_blank: 'select category'
      f.input :product_image, as: :file, hint: 'Upload product image'
      f.input :name
      f.input :code
      f.input :manufacturer
      f.input :dosage
      f.input :features
      f.input :description, as: :text, input_html: { style: 'width: 50%; height: 100px; resize: vertical;' }
      f.input :images, as: :file, hint: 'Upload product images', input_html: { multiple: true }
    end

    f.inputs 'Product Variants' do
      f.has_many :product_variants, heading: 'Product Variants', new_record: 'Add Variant' do |v|
        v.input :size
        v.input :price
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
      row :total_price
      row :images do |product|
        product.images.attached? ? (product.images.map { |img| image_tag url_for(img), size: '100x100', controls: true }.join.html_safe) : 'No images attached'
      end
      row :created_at
      row :updated_at
    end

    panel 'Product Variants' do
      table_for product.product_variants do
        column :size
        column :price
        column :quantity
        column :total_price
      end
    end
  end

  index do
    selectable_column
    id_column
    column :product_image do |product|
      product.product_image.attached? ? (image_tag url_for(product.product_image), width: '50') : 'No image attached'
    end
    column :category
    column :name
    column :code
    column :manufacturer
    column :total_price

    actions

    table_for Product do
      column('Total Product') { products.count }
      column('Total Amount') { products.sum(:total_price) }
    end
  end
end
