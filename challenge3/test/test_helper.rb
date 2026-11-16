ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module TestDataHelpers
  def create_monthly_sale(store:, month:, category: "fiction", channel: "web", sales: 100,
                          profit: 25, orders: 2, returns: 0)
    MonthlySale.create!(
      store: store,
      month: Date.strptime(month, "%Y-%m"),
      category_id: category,
      channel: channel,
      sales_ex_tax: sales,
      gross_profit_ex_tax: profit,
      orders: orders,
      returns: returns
    )
  end
end

class ActiveSupport::TestCase
  include TestDataHelpers
end
