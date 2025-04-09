ActiveAdmin.register HelplineNumber do
  menu priority: 4, label: 'Helpline Numbers'

  permit_params :phone_number, :region

  filter :phone_number
  filter :region
  filter :created_at
  filter :updated_at

  config.sort_order = 'created_at_desc'

  form do |f|
    f.semantic_errors

    f.inputs do
      f.input :phone_number
      f.input :region
    end

    f.actions
  end

  show do
    attributes_table do
      row :phone_number
      row :region
      row :created_at
      row :updated_at
    end
  end

  index do
    selectable_column

    column('No.', sortable: :created_at) do |helpline|
      HelplineNumber.order(:created_at).pluck(:id).index(helpline.id) + 1
    end

    column :phone_number
    column :region

    actions
  end
end
