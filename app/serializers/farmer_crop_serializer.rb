class FarmerCropSerializer < BaseSerializer
  attribute :name do |farmer_crop|
    farmer_crop.farmer_crop_name.name
  end

  attribute :type do |farmer_crop|
    farmer_crop.farmer_crop_type_name.name
  end

  attributes :variety, :description, :moisture_content, :quantity, :price, :contact_number

  attribute :first_name do |farmer_crop|
    farmer_crop.farmer.first_name
  end

  attribute :last_name do |farmer_crop|
    farmer_crop.farmer.last_name
  end

  attribute :address do |farmer_crop|
    farmer_crop.farmer.address
  end

  attribute :state do |farmer_crop|
    farmer_crop.farmer.state
  end

  attribute :district do |farmer_crop|
    farmer_crop.farmer.district
  end

  attribute :village do |farmer_crop|
    farmer_crop.farmer.village
  end

  attribute :pincode do |farmer_crop|
    farmer_crop.farmer.pincode
  end

  attribute :farmer_crop_images do |farmer_crop|
    if farmer_crop.farmer_crop_images.attached?
      farmer_crop.farmer_crop_images.map do |image|
        base_url + Rails.application.routes.url_helpers.rails_blob_path(image, only_path: true)
      end
    else
      []
    end
  end

  attributes :created_at, :updated_at
  
  attribute :reviews, if: proc { |_record, params| params && params[:include_reviews] } do |farmer_crop, params|
    ReviewSerializer.new(
      farmer_crop.reviews.order(created_at: :desc),
      { params: { current_user_id: params[:current_user_id] } }
    ).serializable_hash[:data].map { |d| d[:attributes] }
  end
end
