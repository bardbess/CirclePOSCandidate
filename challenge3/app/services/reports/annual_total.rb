require "bigdecimal"

module Reports
  class AnnualTotal
    attr_reader :monthly_results

    def initialize(query)
      @current_total = decimal(0)
      @previous_total = decimal(0)

      @monthly_results = 12.times.map do |offset|
        current_month = current_start + offset.months
        previous_month = current_month - 12.months

        current = totals_by_month.fetch(current_month, zero_totals)
        previous = totals_by_month.fetch(previous_month, zero_totals)

        @current_total += current.fetch(:sales)
        @previous_total += previous.fetch(:sales)

        month_result(current_month, current, previous)
      end
    end

    def current_total
      money(@current_total)
    end

    def previous_total
      money(@previous_total)
    end

    # A percentage change is undefined when the comparison-period value is zero.
    def percentage_delta
      return nil if @previous_total.zero?

     money(((@current_total - @previous_total) / @previous_total) * 100)
    end

    private

    def money(value)
      value.round(2).to_f
    end

    def decimal(value)
      BigDecimal(value.to_s)
    end

    def month_result(month, current, previous)
      {
        "month" => month.strftime("%Y-%m"),
        "current_year_sales_ex_tax" => money(current.fetch(:sales)),
        "current_year_gross_profit_ex_tax" => money(current.fetch(:gross_profit)),
        "previous_year_sales_ex_tax" => money(previous.fetch(:sales)),
        "previous_year_gross_profit_ex_tax" => money(previous.fetch(:gross_profit)),
        "delta_sales_amount" => money(current.fetch(:sales) - previous.fetch(:sales)),
        "delta_sales_pct" => percentage_delta(current.fetch(:sales), previous.fetch(:sales)),
        "delta_gross_profit_amount" => money(current.fetch(:gross_profit) - previous.fetch(:gross_profit)),
        "delta_gross_profit_pct" => percentage_delta(current.fetch(:gross_profit), previous.fetch(:gross_profit)),
        "orders" => current.fetch(:orders),
        "returns" => current.fetch(:returns)
      }
    end
  end
end

