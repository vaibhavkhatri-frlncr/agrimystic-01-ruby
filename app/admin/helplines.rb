ActiveAdmin.register Helpline, as: 'Helpline Number' do
  permit_params :phone_number

  actions :index, :show, :edit, :update, :destroy

  form do |f|
    f.semantic_errors

    f.inputs do
      f.input :phone_number
    end

    f.actions
  end

  show do
    attributes_table do
      row :phone_number
      row :created_at
      row :updated_at
    end
  end

  index do
    selectable_column
    id_column
    column :phone_number

    actions
  end

  controller do
    def new
      if Helpline.exists?
        flash[:alert] = 'You can only create one Helpline Number.'
        redirect_to admin_helpline_numbers_path
      else
        super
      end
    end

    def create
      if Helpline.exists?
        flash[:alert] = 'You can only create one Helpline Number.'
        redirect_to admin_helpline_numbers_path
      else
        super
      end
    end
  end
end
