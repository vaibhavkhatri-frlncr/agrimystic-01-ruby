ActiveAdmin.register ProductVariant do
  menu parent: 'Product Management', priority: 3

  permit_params :size, :price, :quantity, :product_id

  config.sort_order = 'created_at_desc'

  filter :product
  filter :size
  filter :price
  filter :quantity
  filter :created_at
  filter :updated_at

  form do |f|
    f.semantic_errors

    f.inputs 'Product Variant Details' do
      f.input :product, include_blank: 'select product'
      f.input :size
      f.input :price
      f.input :quantity
    end

    f.actions
  end

  show do
    attributes_table do
      row :id
      row :product
      row :size
      row :price
      row :quantity
      row :created_at
      row :updated_at
    end
  end

  index do
    selectable_column

    column('No.', sortable: :created_at) do |variant|
      ProductVariant.order(:created_at).pluck(:id).index(variant.id) + 1
    end

    column :product
    column :size
    column :price
    column :quantity

    actions
  end
end
