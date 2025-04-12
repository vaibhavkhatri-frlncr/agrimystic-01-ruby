ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { "Dashboard" }

  content title: proc { "Welcome to Agrimystic Admin" } do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        span "Welcome to the Agrimystic Admin Panel"
        small "Manage Crops with Schedules and Diseases, organize Products by Categories, and more!"
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
              div class: "empty-message" do
                span "🗃️ No Products Recorded"
                small "Add products to this category to see them here."
              end
            end
          end
        end
      else
        div class: "empty-message" do
          span "🚫 No Categories Found"
          small "Start by creating a new category."
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
              div class: "empty-message" do
                span "📅 No Schedule Recorded"
                small "Add a schedule to this crop to see it here."
              end
            end
          end
        end
      else
        div class: "empty-message" do
          span "🌱 No Crops Found"
          small "Add crops to manage their schedule."
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
                  li "#{index + 1}. #{disease.disease_name}"
                end
              end
            else
              div class: "empty-message" do
                span "🦠 No Diseases Recorded"
                small "Add diseases to this crop to see them here."
              end
            end
          end
        end
      else
        div class: "empty-message" do
          span "🌾 No Crops Available"
          small "Add crops to manage their diseases."
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
            div class: "empty-message" do
              span "📦 No Categories Yet"
              small "You can add categories for your products."
            end
          end
        end
      end

      column do
        panel "All Helpline Numbers" do
          numbers = HelplineNumber.order(created_at: :asc)
          if numbers.any?
            ul do
              numbers.each_with_index.map do |help, index|
                li "#{index + 1}. #{help.region} - #{help.phone_number}"
              end
            end
          else
            div class: "empty-message" do
              span "📞 No Helpline Numbers"
              small "You can add support numbers for various regions."
            end
          end
        end
      end
    end
  end
end
