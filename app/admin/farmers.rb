ActiveAdmin.register Farmer do
  menu parent: "User Management", priority: 1

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
      params[:farmer][:otp_verified] = true
      super
    end
  end

  filter :full_name
  filter :full_phone_number
  filter :address
  filter :date_of_birth
  filter :activated
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
      f.input :full_name, required: true
      f.input :first_name, required: true
      f.input :last_name, required: true
      f.input :full_phone_number
      f.input :address
      f.input :date_of_birth, as: :date_select, start_year: Date.current.year - 100, end_year: Date.current.year
      if f.object.new_record?
        f.input :password, as: :string, required: true
      else
        f.input :password, as: :string, input_html: { placeholder: '********' }
      end
      f.input :activated
    end

    f.actions
  end

  show title: 'Farmer Details' do
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

    panel 'Farmer Addresses' do
      if resource.addresses.any?
        table_for resource.addresses.order(created_at: :asc) do
          column('No.') { |address| resource.addresses.order(:created_at).index(address) + 1 }
          column :name
          column :mobile
          column :address
          column :pincode
          column :state
          column :district
          column :address_type do |address|
            case address.address_type
            when 'home' then '🏠 Home'
            when 'office' then '🏢 Office'
            when 'other' then '📦 Other'
            else address.address_type
            end
          end
          column :default_address
          column :created_at
          column :updated_at
        end
      else
        div { 'No addresses associated with this farmer.' }
      end
    end
  end

  index title: 'Farmers' do
    selectable_column

    column('No.', sortable: :created_at) do |farmer|
      Farmer.where(otp_verified: true).order(:created_at).pluck(:id).index(farmer.id) + 1
    end

    column :full_name
    column :full_phone_number
    column :address
    column :date_of_birth
    column :activated do |farmer|
      farmer.activated? ? status_tag('yes') : status_tag('no')
    end

    actions
  end
end
