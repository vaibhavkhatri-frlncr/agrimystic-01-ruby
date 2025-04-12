ActiveAdmin.register HelplineNumber do
  menu priority: 4, label: 'Helpline Numbers'

  permit_params :phone_number, :region

  filter :phone_number
  filter :region
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
