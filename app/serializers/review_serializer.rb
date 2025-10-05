class ReviewSerializer < BaseSerializer
  attributes :rating, :review

  attribute :trader_name do |object|
    object.trader.full_name
  end

  attribute :trader_phone_number do |object|
    object.trader.phone_number
  end

  attribute :trader_address do |object|
    object.trader.address
  end

  attribute :is_created_by_me do |object, params|
    params && params[:current_user_id].present? && object.trader_id == params[:current_user_id]
  end

  attributes :created_at, :updated_at
end
