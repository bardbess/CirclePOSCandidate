require "test_helper"

module Api
  class MonthlyComparisonsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @store = Store.create!(
        id: "demo-auckland",
        name: "Demo Auckland",
        reporting_through: Date.new(2025, 12, 1)
      )

      create_monthly_sale(store: @store, month: "2024-01", sales: 100, profit: 20, orders: 2, returns: 1)
      create_monthly_sale(store: @store, month: "2025-01", sales: 150, profit: 35, orders: 3, returns: 0)
    end

    test "returns a valid month comparison response" do
      get "/api/monthly-comparison", params: { store_id: @store.id, months: 24 }

      assert_response :success
      body = response.parsed_body

      assert_equal "frontend-analytics-v2", body[:contract]
      assert_equal "demo-auckland", body[:store_id]
      assert_equal 24, body.dig(:filters_applied, :months)
      assert_equal 12, body[:months].length

      january = body[:months].find { |row| row[:month] == "2025-01" }

      assert_equal 150.0, january[:current_year_sales_ex_tax]
      assert_equal 100.0, january[:previous_year_sales_ex_tax]
      assert_equal 50.0,  january[:delta_sales_pct]
      assert_equal 3,     january[:orders]
      assert_equal 0,     january[:returns]

      assert_equal 150.0, body.dig(:summary, :current_year_sales_ex_tax)
      assert_equal 100.0, body.dig(:summary, :previous_year_sales_ex_tax)
    end

    test "applies category and channel filters" do
      create_monthly_sale(store: @store,       month: "2025-01",
                          category: "fiction", channel: "in_store", sales: 500)
      create_monthly_sale(store: @store,           month: "2025-01",
                          category: "non-fiction", channel: "web", sales: 300)

      get "/api/monthly-comparison",
          params: { store_id: @store.id, months: 24,
                    category_id: "fiction", channel: "web" }

      assert_response :success
      body = response.parsed_body

      assert_equal "fiction", body.dig(:filters_applied, :category_id)
      assert_equal "web", body.dig(:filters_applied, :channel)

      january = body[:months].find { |row| row[:month] == "2025-01" }

      assert_equal 150.0, january[:current_year_sales_ex_tax]
    end

    test "zero fills missing months and returns nil percentage" do
      get "/api/monthly-comparison", params: { store_id: @store.id }

      assert_response :success
      rows = response.parsed_body[:months]

      february = rows.find { |row| row[:month] == "2025-02" }

      assert_equal 0.0, february[:current_year_sales_ex_tax]
      assert_equal 0.0, february[:previous_year_sales_ex_tax]
      assert_nil february[:delta_sales_pct]
    end

    test "does not cap unusually large values" do
      create_monthly_sale(store: @store, month: "2025-02", sales: 1_000_000, profit: 250_000)

      get "/api/monthly-comparison", params: { store_id: @store.id }

      assert_response :success

      february = response.parsed_body[:months].find { |row| row[:month] == "2025-02" }

      assert_equal 1_000_000.0, february[:current_year_sales_ex_tax]
    end

  end
end
