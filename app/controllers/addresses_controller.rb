class AddressesController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated
  before_action :load_address, only: [:show, :update, :destroy]

  def index
    addresses = current_user.addresses

    if addresses.any?
      render json: AddressSerializer.new(addresses), status: :ok
    else
      render json: { errors: [{ message: 'No addresses found.' }] }, status: :not_found
    end
  end

  def show
    return if @address.nil?
    render json: AddressSerializer.new(@address), status: :ok
  end

  def create
    address = current_user.addresses.build(address_params)

    if address.default_address
      unset_other_default_addresses
    end

    if address.save
      render json: { address: AddressSerializer.new(address), message: 'Address created successfully' }, status: :created
    else
      render json: { errors: format_activerecord_errors(address.errors) }, status: :unprocessable_entity
    end
  end

  def update
    if address_params[:default_address] == true || address_params[:default_address] == "true"
      unset_other_default_addresses
    end

    if @address.update(address_params)
      render json: { address: AddressSerializer.new(@address), message: 'Address updated successfully' }, status: :ok
    else
      render json: { errors: format_activerecord_errors(@address.errors) }, status: :unprocessable_entity
    end
  end

  def destroy
    total_addresses = current_user.addresses.count
  
    if total_addresses <= 1
      render json: {
        errors: [{ message: 'At least one address must be present. You cannot delete your only saved address.' }]
      }, status: :unprocessable_entity and return
    end
  
    if @address.default_address
      render json: {
        errors: [{ message: 'Cannot delete the default address. Please set another address as default before deleting this one.' }]
      }, status: :unprocessable_entity and return
    end
  
    if @address.destroy
      render json: { message: 'Address deleted successfully.' }, status: :ok
    else
      render json: {
        errors: [{ message: 'Something went wrong while trying to delete the address. Please try again later.' }]
      }, status: :unprocessable_entity
    end
  end  

  private

  def load_address
    @address = current_user.addresses.find_by(id: params[:id])

    if @address.nil?
      render json: { errors: [{ message: "No address found with ID #{params[:id]} for the current user." }] }, status: :not_found
    end
  end

  def address_params
    params.require(:address).permit(
      :name,
      :mobile,
      :address,
      :pincode,
      :state,
      :district,
      :address_type,
      :default_address
    )
  end

  def unset_other_default_addresses
    current_user.addresses.where(default_address: true).update_all(default_address: false)
  end

  def format_activerecord_errors(errors)
    errors.messages.map { |attribute, error| { attribute => error } }
  end
end
