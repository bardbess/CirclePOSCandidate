require "bigdecimal"

module Reports
  class AnnualTotal
    attr_reader :monthly_results, :first_month

    def initialize(query, first_month: )
      @current_total = decimal(0)
      @previous_total = decimal(0)

      current_start = first_month + 12.months

      @monthly_results = 12.times.map do |offset|
        current_month = current_start + offset.months
        previous_month = current_month - 12.months

        current = query.fetch(current_month, zero_totals)
        previous = query.fetch(previous_month, zero_totals)

        @current_total += current[:sales]
        @previous_total += previous[:sales]

        month_result(current_month, current, previous)
      end
    end

    def current_total
      money(@current_total)
    end

    def previous_total
      money(@previous_total)
    end

    def percentage_delta_total
      percentage_delta(@current_total, @previous_total)
    end


    def zero_totals
      { sales: decimal(0), gross_profit: decimal(0), orders: 0, returns: 0 }
    end


    private

    # A percentage change is undefined when the comparison-period value is zero.
    def percentage_delta(current_val, previous_val)
      return nil if current_val.zero?

     money(((current_val - previous_val) / previous_val) * 100)
    end

    def money(value)
      value.round(2).to_f
    end

    def decimal(value)
      BigDecimal(value.to_s)
    end

    def month_result(month, current, previous)
      {
        month: month.strftime("%Y-%m"),
        current_year_sales_ex_tax: money(current[:sales]),
        current_year_gross_profit_ex_tax: money(current[:gross_profit]),
        previous_year_sales_ex_tax: money(previous[:sales]),
        previous_year_gross_profit_ex_tax: money(previous[:gross_profit]),
        delta_sales_amount: money(current[:sales] - previous[:sales]),
        delta_sales_pct: percentage_delta(current[:sales], previous[:sales]),
        delta_gross_profit_amount: money(current[:gross_profit] - previous[:gross_profit]),
        delta_gross_profit_pct: percentage_delta(current[:gross_profit], previous[:gross_profit]),
        orders: current[:orders],
        returns: current[:returns]
      }
    end
  end
end

