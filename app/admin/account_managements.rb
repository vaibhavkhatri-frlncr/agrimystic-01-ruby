ActiveAdmin.register Account do
	menu priority: 3, label: 'Account Management'

	permit_params :full_name, :first_name, :last_name, :full_phone_number, :address, :date_of_birth, :password, :otp_verified, :activated

	filter :full_name
	filter :first_name
	filter :last_name
	filter :full_phone_number
	filter :address
	filter :otp_verified
	filter :activated
	filter :date_of_birth
	filter :created_at
	filter :updated_at

	form do |f|
		f.semantic_errors

		f.inputs do
			f.input :full_name
			f.input :first_name
			f.input :last_name
			f.input :full_phone_number
			f.input :address
			f.input :date_of_birth, as: :date_select, start_year: Date.current.year - 100, end_year: Date.current.year
			f.object.new_record? ? (f.input :password, as: :string) : (f.input :password, as: :string, input_html: { placeholder: '********' })
			f.input :otp_verified
			f.input :activated
		end

		f.actions
	end

	show title: 'Account Details' do
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
			row :otp_verified
			row :activated
			row :date_of_birth
			row :created_at
      row :updated_at
		end

		panel 'Addresses' do
			if resource.addresses.any?
				table_for resource.addresses do
					column :name
					column :mobile
					column :address
					column :pincode
					column :state
					column :district
					column :address_type
					column :default_address
					column :created_at
					column :updated_at
				end
			else
				div do
					'No addresses associated with this account.'
				end
			end
		end
	end

	index title: 'Account' do
		selectable_column
		id_column
		column :full_name
		column :full_phone_number
		column :address
		column :otp_verified do |user|
			user.otp_verified? ? status_tag( 'yes' ) : status_tag( 'no' )
		end
		column :activated do |user|
			user.activated? ? status_tag( 'yes' ) : status_tag( 'no' )
		end
		column :date_of_birth

		actions
	end
end
