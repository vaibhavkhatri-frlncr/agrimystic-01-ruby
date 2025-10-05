ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { "Dashboard" }

  content title: proc { "Welcome to Agrimystic Admin" } do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        span "Welcome to the Agrimystic Admin Panel"
        small "Manage Crops with Types, Schedule, and Diseases, organize Products by Categories, and more!"
      end
    end

    div style: "margin-bottom: 20px;" do
    end

    # Product Overview
    panel "Product Overview (Category → Products → Variants)" do
      categories = Category.order(created_at: :asc).to_a
      if categories.any?
        table_for categories do
          column("No.") { |category| categories.index(category) + 1 }
          column("Category") { |category| category.name }
          column("Products") do |category|
            if category.products.any?
              ul do
                category.products.order(created_at: :asc).each_with_index.map do |product, index|
                  li do
                    span "#{index + 1}. #{product.name} "
                    small "(#{product.product_variants.count} Variants)"
                  end
                end
              end
            else
              div class: "empty-message", style: "text-align: center; padding: 10px; background-color: #f9f9f9; border-radius: 10px; display: flex; align-items: center; justify-content: center;" do
                span style: "font-size: 24px; margin-right: 10px;" do
                  "🗃️"
                end
                span "No Products Recorded"
                small do
                  "Add products to this category to see them here."
                  a "Add Product", href: new_admin_product_path, style: "color: #007bff; margin-left: 5px;"
                end
              end
            end
          end
        end
      else
        div class: "empty-message", style: "text-align: center; padding: 20px; background-color: #f8f9fa; border-radius: 10px;" do
          span style: "font-size: 30px;" do
            "🚫"
          end
          br
          span "No Categories Found"
          br
          small do
            "Start by creating a new category."
            a "Create Category", href: new_admin_category_path, style: "color: #007bff;"
          end
        end
      end
    end

    # Crops and Their Schedule
    panel "Crops and Their Schedule" do
      crops = Crop.order(created_at: :asc).to_a
      if crops.any?
        table_for crops do
          column("No.") { |crop| crops.index(crop) + 1 }
          column("Crop") { |crop| crop.name }
          column("Schedule") do |crop|
            if crop.crop_schedule.present?
              crop.crop_schedule.heading
            else
              div class: "empty-message", style: "text-align: center; padding: 10px; background-color: #f9f9f9; border-radius: 10px; display: flex; align-items: center; justify-content: center;" do
                span style: "font-size: 24px; margin-right: 10px;" do
                  "📅"
                end
                span "No Schedule Recorded"
                small do
                  "Add a schedule to this crop to see it here."
                  a "Add Schedule", href: new_admin_crop_schedule_path, style: "color: #007bff; margin-left: 5px;"
                end
              end
            end
          end
        end
      else
        div class: "empty-message", style: "text-align: center; padding: 20px; background-color: #f8f9fa; border-radius: 10px;" do
          span style: "font-size: 30px;" do
            "🌱"
          end
          br
          span "No Crops Found"
          br
          small do
            "Add crops to manage their schedule."
            a "Create Crop", href: new_admin_crop_path, style: "color: #007bff;"
          end
        end
      end
    end

    # Crops and Their Diseases
    panel "Crops and Their Diseases" do
      crops = Crop.order(created_at: :asc).to_a
      if crops.any?
        table_for crops do
          column("No.") { |crop| crops.index(crop) + 1 }
          column("Crop") { |crop| crop.name }
          column("Diseases") do |crop|
            if crop.crop_diseases.any?
              ul do
                crop.crop_diseases.order(created_at: :asc).each_with_index.map do |disease, index|
                  li "#{index + 1}. #{disease.name}"
                end
              end
            else
              div class: "empty-message", style: "text-align: center; padding: 10px; background-color: #f9f9f9; border-radius: 10px; display: flex; align-items: center; justify-content: center;" do
                span style: "font-size: 24px; margin-right: 10px;" do
                  "🦠"
                end
                span "No Diseases Recorded"
                small do
                  "Add diseases to this crop to see them here."
                  a "Add Disease", href: new_admin_crop_disease_path, style: "color: #007bff; margin-left: 5px;"
                end
              end
            end
          end
        end
      else
        div class: "empty-message", style: "text-align: center; padding: 20px; background-color: #f8f9fa; border-radius: 10px;" do
          span style: "font-size: 30px;" do
            "🐛"
          end
          br
          span "No Crops Found"
          br
          small do
            "Add crops to manage their diseases."
            a "Create Crop", href: new_admin_crop_path, style: "color: #007bff;"
          end
        end
      end
    end

    # Farmer Crops and Their Types
    panel "Farmer Crops and Their Types" do
      farmer_crops = FarmerCropName.order(created_at: :asc).to_a

      if farmer_crops.any?
        table_for farmer_crops do
          column("No.") { |crop| farmer_crops.index(crop) + 1 }
          column("Crop") { |crop| crop.name }
          column("Types") do |crop|
            if crop.farmer_crop_type_names.any?
              ul do
                crop.farmer_crop_type_names.order(:created_at).each_with_index.map do |type, index|
                  li "#{index + 1}. #{type.name}"
                end
              end
            else
              div class: "empty-message", style: "text-align: center; padding: 10px; background-color: #f9f9f9; border-radius: 10px; display: flex; align-items: center; justify-content: center;" do
                span style: "font-size: 20px; margin-right: 10px;" do
                  "⚠️"
                end
                span "No Types Recorded"
                small do
                  "Add types to this crop to see them here."
                  a "Add Type", href: new_admin_farmer_crop_type_name_path, style: "color: #007bff; margin-left: 5px;"
                end
              end
            end
          end
        end
      else
        div class: "empty-message", style: "text-align: center; padding: 20px; background-color: #f8f9fa; border-radius: 10px;" do
          span style: "font-size: 28px;" do
            "🌾"
          end
          br
          span "No Farmer Crops Found"
          br
          small do
            "Add farmer crop names to manage their types."
            a "Create Farmer Crop", href: new_admin_farmer_crop_name_path, style: "color: #007bff;"
          end
        end
      end
    end

    # Categories and Helplines
    columns do
      column do
        panel "Product Categories" do
          categories = Category.order(created_at: :asc)
          if categories.any?
            ul do
              categories.each_with_index.map do |cat, index|
                li "#{index + 1}. #{cat.name}"
              end
            end
          else
            div class: "empty-message", style: "text-align: center; padding: 20px; background-color: #f8f9fa; border-radius: 10px;" do
              span style: "font-size: 28px;" do
                "📦"
              end
              br
              span "No Categories Found"
              br
              small do
                "You can add categories for your products."
                a "Create Category", href: new_admin_category_path, style: "color: #007bff;"
              end
            end
          end
        end
      end

      column do
        panel "Helpline Numbers" do
          numbers = HelplineNumber.order(created_at: :asc)
          if numbers.any?
            ul do
              numbers.each_with_index.map do |help, index|
                li "#{index + 1}. #{help.region} - #{help.phone_number}"
              end
            end
          else
            div class: "empty-message", style: "text-align: center; padding: 20px; background-color: #f8f9fa; border-radius: 10px;" do
              span style: "font-size: 28px;" do
                "📞"
              end
              br
              span "No Helpline Numbers Found"
              br
              small do
                "You can add support numbers for various regions."
                a "Create Helpline Number", href: new_admin_helpline_number_path, style: "color: #007bff;"
              end
            end
          end
        end
      end
    end
  end
end
