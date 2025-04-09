ActiveAdmin.register Category do
  menu parent: 'Product Management', priority: 1

  permit_params :name

  filter :name
  filter :created_at
  filter :updated_at

  config.sort_order = 'created_at_desc'

  form do |f|
    f.semantic_errors

    f.inputs do
      f.input :name
    end

    f.actions
  end

  show do
    attributes_table do
      row :name
      row :created_at
      row :updated_at
    end
  end

  index do
    selectable_column

    column('No.', sortable: :created_at) do |category|
      Category.order(:created_at).pluck(:id).index(category.id) + 1
    end

    column :name
    column :created_at
    actions
  end
end
