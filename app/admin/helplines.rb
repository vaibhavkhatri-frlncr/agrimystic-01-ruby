ActiveAdmin.register Helpline, as: 'Helpline Number' do
  menu priority: 4, label: 'Helpline Number'

  permit_params :phone_number, :region

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
    id_column
    column :phone_number
    column :region

    actions
  end
end
