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

    # === Product Overview (Category → Products → Variants) ===
    panel "Product Overview (Category → Products → Variants)" do
      categories = Category.order(created_at: :asc).to_a
      table_for categories do
        column("No.") { |category| categories.index(category) + 1 }
        column("Category") { |category| category.name }
        column("Products") do |category|
          ul do
            category.products.order(created_at: :asc).each_with_index.map do |product, index|
              li do
                span "#{index + 1}. #{product.name} "
                small "(#{product.product_variants.count} Variants)"
              end
            end
          end
        end
      end
    end

    # === Crops and Their Schedule ===
    panel "Crops and Their Schedule" do
      crops = Crop.order(created_at: :asc).to_a
      table_for crops do
        column("No.") { |crop| crops.index(crop) + 1 }
        column("Crop") { |crop| crop.name }
        column("Schedule") { |crop| crop.crop_schedule&.heading || "No Schedule Assigned" }
      end
    end

    # === Crops and Their Diseases ===
    panel "Crops and Their Diseases" do
      crops = Crop.order(created_at: :asc).to_a
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
            status_tag "No Diseases", "warning"
          end
        end
      end
    end

    # === Recent Entries Summary ===
    columns do
      column do
        panel "Product Categories" do
          categories = Category.order(created_at: :asc)
          ul do
            categories.each_with_index.map do |cat, index|
              li "#{index + 1}. #{cat.name}"
            end
          end
        end
      end

      column do
        panel "All Helpline Numbers" do
          numbers = HelplineNumber.order(created_at: :asc)
          ul do
            numbers.each_with_index.map do |help, index|
              li "#{index + 1}. #{help.region} - #{help.phone_number}"
            end
          end
        end
      end
    end
  end
end
