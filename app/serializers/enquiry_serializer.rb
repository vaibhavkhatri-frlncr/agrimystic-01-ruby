class EnquirySerializer < BaseSerializer
  attributes :id, :message

  attribute :trader_name do |object|
    object.trader.full_name
  end

  attribute :trader_phone_number do |object|
    object.trader.phone_number
  end

  attribute :trader_address do |object|
    object.trader.address
  end

  attribute :crop_name do |object|
    object.farmer_crop.farmer_crop_name.name
  end

  attribute :crop_type do |object|
    object.farmer_crop.farmer_crop_type_name.name
  end

  attribute :quantity do |object|
    object.farmer_crop.quantity
  end

  attribute :price do |object|
    object.farmer_crop.price
  end

  attributes :created_at, :updated_at
end
