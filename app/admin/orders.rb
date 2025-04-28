ActiveAdmin.register Order do
  actions :index, :show

  config.clear_action_items!

  includes :account, :address, :order_products

  filter :account
  filter :address_address, as: :string, label: 'Address'
  filter :payment_method, as: :select, collection: [['COD', 'cod'], ['Online', 'online']]
  filter :payment_status, as: :select, collection: [['Pending', 'pending'], ['Completed', 'completed'], ['Failed', 'failed']]
  filter :order_status, as: :select, collection: [['Placed', 'placed'], ['Processing', 'processing'], ['Shipped', 'shipped'], ['Delivered', 'delivered'], ['Cancelled', 'cancelled']]
  filter :placed_at
  filter :paid_at
  filter :created_at
  filter :updated_at

  show do
    attributes_table do
      row('User') { |order| order.account.try(:full_name) || order.account.try(:phone_number) || order.account_id }
      row('Address') { order.address.try(:address) }
      row :payment_method do |order|
        order.payment_method == 'online' ? '💳 Online' : '💵 COD'
      end
      row :payment_status do |order|
        case order.payment_status
        when 'completed'
          status_tag '✅ Completed', class: 'status_tag yes'
        when 'pending'
          status_tag '⏳ Pending', class: 'status_tag yellow'
        when 'failed'
          status_tag '❌ Failed', class: 'status_tag no'
        else
          order.payment_status
        end
      end
      row :order_status do |order|
        case order.order_status
        when 'placed'
          status_tag 'Placed', class: 'status_tag yellow'
        when 'processing'
          status_tag 'Processing', class: 'status_tag cyan'
        when 'shipped'
          status_tag 'Shipped', class: 'status_tag blue'
        when 'delivered'
          status_tag 'Delivered', class: 'status_tag yes'
        when 'cancelled'
          status_tag 'Cancelled', class: 'status_tag no'
        else
          order.order_status
        end
      end
      row('Total Amount') { "₹#{order.total_amount}" }
      row :razorpay_order_id
      row :razorpay_payment_id
      row :placed_at
      row :paid_at
      row :cancelled_at
      row :created_at
      row :updated_at
    end

    panel 'Order Products' do
      if resource.order_products.any?
        table_for resource.order_products.order(:created_at) do
          column('No.') { |op| resource.order_products.order(:created_at).index(op) + 1 }
          column('Product') do |op|
            op.product_variant&.product&.name || op.product_variant&.id
          end
          column('Size') do |op|
            op.product_variant&.size || 'N/A'
          end
          column :quantity
          column('Price per unit') { |op| "₹#{op.price}" }
          column('Total Value') { |op| "₹#{op.total_price}" }
          column :created_at
          column :updated_at
        end
      else
        div do
          'No products associated with this order.'
        end
      end
    end
  end

  index title: 'Orders' do
    selectable_column

    column('No.', sortable: :created_at) do |order|
      Order.order(:created_at).pluck(:id).index(order.id) + 1
    end

    column 'User' do |order|
      order.account.try(:full_name) || order.account.try(:phone_number) || order.account_id
    end

    column 'Address' do |order|
      order.address.try(:address) || order.address_id
    end

    column :payment_method do |order|
      order.payment_method == 'online' ? '💳 Online' : '💵 COD'
    end

    column :payment_status do |order|
      case order.payment_status
      when 'completed'
        status_tag '✅ Completed', class: 'status_tag yes'
      when 'pending'
        status_tag '⏳ Pending', class: 'status_tag yellow'
      when 'failed'
        status_tag '❌ Failed', class: 'status_tag no'
      else
        order.payment_status
      end
    end

    column :order_status do |order|
      case order.order_status
      when 'placed'
        status_tag 'Placed', class: 'status_tag yellow'
      when 'processing'
        status_tag 'Processing', class: 'status_tag cyan'
      when 'shipped'
        status_tag 'Shipped', class: 'status_tag blue'
      when 'delivered'
        status_tag 'Delivered', class: 'status_tag yes'
      when 'cancelled'
        status_tag 'Cancelled', class: 'status_tag no'
      else
        order.order_status
      end
    end

    column('Total Amount') { |order| "₹#{order.total_amount}" }
    column :placed_at

    actions
  end
end
