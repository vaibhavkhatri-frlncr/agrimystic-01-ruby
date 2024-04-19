ActiveAdmin.register Account, as: 'User' do

	menu label: 'User Management'

	permit_params :type, :full_name, :first_name, :last_name, :full_phone_number, :address, :date_of_birth, :password, :activated

	filter :full_name
	filter :first_name
	filter :last_name
	filter :full_phone_number
	filter :address
	filter :activated
	filter :date_of_birth
	filter :created_at
	filter :updated_at

	index title: 'User' do
		selectable_column
		id_column
		column :full_name
		column :full_phone_number
		column :address
		column :activated do |user|
			user.activated? ? status_tag( 'yes' ) : status_tag( 'no' )
		end
		column :date_of_birth
		actions
	end

	show title: 'User Details' do
		attributes_table do
			row :full_name
			row :first_name
			row :last_name
			row :full_phone_number
			row :address
			row :state
			row :district
			row :village
			row :pincode
			row :activated
			row :date_of_birth
			div do
				link_to 'Back', admin_users_path, class: 'button'
			end
		end    
	end

	form do |f|
		f.semantic_errors
		f.inputs do
			f.input :type, as: :hidden, input_html: { value: 'SmsAccount' }
			f.input :full_name
			f.input :first_name
			f.input :last_name
			f.input :full_phone_number
			f.input :address
			f.input :date_of_birth, as: :date_select, start_year: Date.current.year - 100, end_year: Date.current.year
			if f.object.new_record?
        f.input :password, as: :string
      else
				f.input :password, as: :string, input_html: { placeholder: '********' }
      end
			f.input :activated
		end
		f.actions
	end
end
