class CartsController < ApplicationController
  before_action :validate_json_web_token
  before_action :check_account_activated
  before_action :load_cart, only: [:add_to_cart, :remove_from_cart, :get_cart_products]

  def add_to_cart
    ActiveRecord::Base.transaction do
      @product_variant = ProductVariant.find_by(id: params[:product_variant_id])
      @price = @product_variant&.price.to_i

      if @product_variant.present?
        if is_product_variant_stock_available
          @cart_product = CartProduct.find_or_initialize_by(cart_id: @cart.id, product_variant_id: @product_variant.id)
          manage_cart_on_add_product
          render json: { data: [{ message: "#{@product_variant.product.name} added to cart successfully" }] }, status: :ok
        else
          raise StandardError, "#{@product_variant.product.name.capitalize} variant is out of stock as per your cart details. Now you can add only #{@product_variant.quantity - (@cart_product&.quantity || 0)} unit(s) of it to your cart"
        end
      else
        render json: { errors: [{ message: "Product variant with id #{params[:product_variant_id]} doesn't exist" }] }, status: :not_found
      end
    end
  rescue StandardError => e
    render_cart_error(e.message)
  end

  def remove_from_cart
    ActiveRecord::Base.transaction do
      @product_variant = ProductVariant.find_by(id: params[:product_variant_id])
      @price = @product_variant&.price.to_i

      if @product_variant.present?
        @cart_product = CartProduct.find_or_initialize_by(cart_id: @cart.id, product_variant_id: @product_variant.id)
        manage_cart_on_remove_product
      else
        render json: { errors: [{ message: "Product variant with id #{params[:product_variant_id]} doesn't exist" }] }, status: :not_found
      end
    end
  rescue StandardError => e
    render_cart_error(e.message)
  end

  def get_cart_products
    cart_products = @cart.cart_products
    serializer = CartProductSerializer.new(cart_products, meta: { cart_total_price: @cart.total_price })
    render json: serializer, status: :ok
  end

  private

  def load_cart
    @cart = current_user.cart || Cart.create(account_id: current_user.id)
  end

  def render_cart_error(message)
    render json: { errors: [{ message: message }] }, status: :unprocessable_entity
  end

  def is_product_variant_stock_available
    @cart_product = CartProduct.find_by(cart_id: @cart.id, product_variant_id: @product_variant.id)
    carted_quantity = @cart_product.present? ? @cart_product.quantity : 0
    @product_variant.quantity >= (params[:quantity].to_i + carted_quantity)
  end

  def manage_cart_on_add_product
    @cart.total_price += @price * params[:quantity].to_i
    @cart_product.quantity += params[:quantity].to_i
    @cart_product.save
    @cart.save
  end

  def manage_cart_on_remove_product
    @cart.total_price -= @price * params[:quantity].to_i
    @cart_product.quantity -= params[:quantity].to_i
    @cart_product.quantity < 0 ? (return render json: { errors: [{ message: "Product variant with id #{params[:product_variant_id]} doesn't exist in cart" }] }, status: :not_found) : (render json: { data: [{ message: "#{@product_variant.product.name} removed from cart successfully" }] }, status: :ok)
    @cart_product.save
    @cart.save
    @cart_product.destroy if @cart_product.quantity.zero?
  end
end
