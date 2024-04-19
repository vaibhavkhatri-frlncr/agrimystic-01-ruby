ActiveAdmin.register Product do
  menu parent: 'Product Management', priority: 1

  permit_params :category_id, :name, :code, :description, :display_picture, product_variants_attributes: [:id, :size, :price, :quantity, :_destroy]

  remove_filter :display_picture_attachment, :display_picture_blob
  filter :category
  filter :name
  filter :description
  filter :code
  filter :total_price
  filter :created_at
  filter :updated_at

  form do |f|
    f.semantic_errors
    f.inputs 'Product Details' do
      f.input :category, include_blank: 'select category'
      f.input :name
      f.input :code
      f.input :description, as: :text, input_html: { style: 'width: 78.5%; height: 100px;' }
      f.input :display_picture, as: :file, hint: f.object.display_picture.attached? ? (image_tag url_for(f.object.display_picture), size: '100x100', controls: true) : 'Upload an display picture for product'
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

  index do
    selectable_column
    id_column
    column 'Display Picture' do |product|
      product.display_picture.attached? ? (image_tag url_for(product.display_picture), width: '50') : 'No image attached'
    end
    column :category
    column :name
    column :description
    column :code
    column :total_price
    actions
  end

  show do
    attributes_table do
      row 'Display Picture' do |product|
        product.display_picture.attached? ? (image_tag url_for(product.display_picture), size: '100x100', controls: true) : 'No image attached'
      end
      row :category
      row :name
      row :code
      row :description
      row :total_price
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
    div do
      link_to 'Back', admin_products_path, class: 'button'
    end
  end
end
