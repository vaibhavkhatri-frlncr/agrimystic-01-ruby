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
          render json: { message: "#{@product_variant.product.name} added to cart successfully." }, status: :ok
        else
          raise StandardError, "#{@product_variant.product.name.capitalize} variant is out of stock as per your cart details. Now you can add only #{@product_variant.quantity - (@cart_product&.quantity || 0)} unit(s) of it to your cart."
        end
      else
        render json: { errors: [{ message: "Product variant with id #{params[:product_variant_id]} doesn't exist." }] }, status: :not_found
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
        render json: { errors: [{ message: "Product variant with id #{params[:product_variant_id]} doesn't exist." }] }, status: :not_found
      end
    end
  rescue StandardError => e
    render_cart_error(e.message)
  end

  def get_cart_products
    page     = params[:page] || 1
    per_page = params[:per_page] || 10

    cart_products = @cart.cart_products.order(created_at: :desc).page(page).per(per_page)

    if cart_products.present?
      render json: {
        cart_products: CartProductSerializer.new(cart_products),
        meta: {
          cart_total_price: @cart.total_price,
          current_page: cart_products.current_page,
          next_page: cart_products.next_page,
          prev_page: cart_products.prev_page,
          total_pages: cart_products.total_pages,
          total_count: cart_products.total_count
        }
      }, status: :ok
    else
      render json: {
        errors: [{ message: "No cart products found." }]
      }, status: :not_found
    end
  end

  private

  def load_cart
    @cart = current_user.cart || Cart.create(farmer_id: current_user.id)
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
    @cart_product.quantity < 0 ? (return render json: { errors: [{ message: "Product variant with id #{params[:product_variant_id]} doesn't exist in cart." }] }, status: :not_found) : (render json: { message: "#{@product_variant.product.name} removed from cart successfully" }, status: :ok)
    @cart_product.save
    @cart.save
    @cart_product.destroy if @cart_product.quantity.zero?
  end
end
