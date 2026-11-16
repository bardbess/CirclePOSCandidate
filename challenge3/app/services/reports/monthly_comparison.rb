require "bigdecimal"

module Reports
  class MonthlyComparison

    attr_reader :store, :request
    attr_accessor :current_sales_total, :previous_sales_total

    # Expects a Report::MonthlyComparisonRequest instance
    def initialize(request:)
      @request = request
      @store = Store.find(id: @request.store_id)
    end

    def store_monthly_sales
      query = store.monthly_sales
      query = query.where(month: first_month..latest_month)
      query = query.where(category_id: request.category_id) if request.category_id
      query.where(channel: request.channel) if request.channel
    end

    def call
      totals_by_month = aggregate_by_month(store_monthly_sales)
      sales = Reports::AnnualTotal.new(totals_by_month)

      {
        store: store,
        filters_applied: {
          months: request.months,
          category_id: request.category_id,
          channel: request.channel
        },
        summary: {
          current_year_sales_ex_tax: sales.current_total,
          previous_year_sales_ex_tax: sales.previous_total,
          delta_sales_pct: sales.percentage_delta
        },
        months: months
      }
    end

    private

    def latest_month
      @latest_month ||= store.latest_month
    end

    def first_month
      @first_month ||= latest_month - (@request.months - 1).months
    end

    def current_start
      first_month + 12.months
    end

    def aggregate_by_month(query)
      rows = query.group(:month).pluck(
        :month,
        Arel.sql("SUM(sales_ex_tax)"),
        Arel.sql("SUM(gross_profit_ex_tax)"),
        Arel.sql("SUM(orders)"),
        Arel.sql("SUM(returns)")
      )

      rows.each_with_object({}) do |(month, sales, profit, orders, returns), totals|
        totals[month.beginning_of_month] = {
          sales: decimal(sales),
          gross_profit: decimal(profit),
          orders: orders.to_i,
          returns: returns.to_i
        }
      end
    end

    def zero_totals
      { sales: decimal(0), gross_profit: decimal(0), orders: 0, returns: 0 }
    end

    def decimal(value)
      BigDecimal(value.to_s)
    end

  end
end
