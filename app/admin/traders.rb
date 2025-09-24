ActiveAdmin.register Trader do
  menu parent: "User Management", priority: 2

  permit_params :full_name, :first_name, :last_name, :full_phone_number, :address, :date_of_birth, :password, :activated

  controller do
    def scoped_collection
      super.where(otp_verified: true)
    end

    def update
      resource.request_source = :admin
      super
    end

    def create
      params[:trader][:otp_verified] = true
      super
    end
  end

  filter :full_name
  filter :first_name
  filter :last_name
  filter :full_phone_number
  filter :address
  filter :date_of_birth
  filter :activated
  filter :created_at
  filter :updated_at

  config.sort_order = 'created_at_desc'

  form do |f|
    f.inputs do
      f.input :full_name
      f.input :first_name
      f.input :last_name
      f.input :full_phone_number
      f.input :address
      f.input :date_of_birth, as: :date_select, start_year: Date.current.year - 100, end_year: Date.current.year
      f.object.new_record? ? (f.input :password, as: :string) : (f.input :password, as: :string, input_html: { placeholder: '********' })
      f.input :activated
    end
    f.actions
  end

  show title: 'Trader Details' do
    attributes_table do
      row :full_name
      row :first_name
      row :last_name
      row :full_phone_number
      row :email
      row :address
      row :date_of_birth
      row :activated
      row :created_at
      row :updated_at
    end
  end

  index title: 'Traders' do
    selectable_column

    column('No.', sortable: :created_at) do |trader|
      Trader.where(otp_verified: true).order(:created_at).pluck(:id).index(trader.id) + 1
    end

    column :full_name
    column :full_phone_number
    column :address
    column :date_of_birth
    column :activated do |trader|
      trader.activated? ? status_tag('yes') : status_tag('no')
    end

    actions
  end
end
