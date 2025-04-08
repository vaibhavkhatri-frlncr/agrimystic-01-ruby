ActiveAdmin.register AdminUser do
  menu priority: 2, label: 'Admin Users'

  permit_params :email, :password, :password_confirmation

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at
  filter :updated_at

  form do |f|
    f.semantic_errors

    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end

    f.actions
  end


  show do
    attributes_table do
      row :email
      row :current_sign_in_at
      row :sign_in_count
      row :created_at
      row :updated_at
    end
  end

  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at

    actions
  end
end
