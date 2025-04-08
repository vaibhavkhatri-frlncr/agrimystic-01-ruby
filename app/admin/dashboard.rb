ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { "Dashboard" }

  content title: proc { "Welcome to Farmade Admin" } do
    div class: "blank_slate_container", id: "dashboard_default_message" do
      span class: "blank_slate" do
        span "Welcome to the Farmade Admin Panel"
        small "Manage Crops, Products, Categories, Schedules, and More!"
      end
    end

    # === Category -> Products -> Variants ===
    panel "Product Overview (Category → Products → Variants)" do
      table_for Category.order(created_at: :desc) do
        column("Category") { |category| category.name }
        column("Products") do |category|
          ul do
            category.products.map do |product|
              li do
                span "#{product.name} "
                small "(#{product.product_variants.count} Variants)"
              end
            end
          end
        end
      end
    end

    # === Crop → CropSchedule ===
    panel "Crops and Their Schedule" do
      table_for Crop.order(created_at: :desc) do
        column("Crop") { |crop| crop.name }
        column("Schedule") do |crop|
          crop.crop_schedule&.heading || "No Schedule Assigned"
        end
      end
    end

    # === Crop → CropDiseases ===
    panel "Crops and Their Diseases" do
      table_for Crop.order(created_at: :desc) do
        column("Crop") { |crop| crop.name }
        column("Diseases") do |crop|
          ul do
            crop.crop_diseases.map do |disease|
              li disease.disease_name
            end
          end
        end
      end
    end

    # === Recent Entries Summary (Now All Records) ===
    columns do
      column do
        panel "Product Categories" do
          ul do
            Category.order(created_at: :desc).map { |cat| li cat.name }
          end
        end
      end

      column do
        panel "All Helpline Numbers" do
          ul do
            HelplineNumber.order(created_at: :desc).map do |help|
              li "#{help.region} - #{help.phone_number}"
            end
          end
        end
      end
    end
  end
end
