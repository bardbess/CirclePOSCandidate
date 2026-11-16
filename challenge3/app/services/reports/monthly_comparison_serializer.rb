module Reports
  # Presentation boundary: maps the reporting result to the published JSON contract.
  class MonthlyComparisonSerializer
    CONTRACT = "frontend-analytics-v2".freeze

    def initialize(result)
      @result = result
    end

    def as_json(*)
      store = @result.fetch(:store)

      {
        contract: CONTRACT,
        store_id: store.id,
        store_name: store.name,
        filters_applied: @result.fetch(:filters_applied),
        summary: @result.fetch(:summary),
        months: @result.fetch(:months)
      }
    end
  end
end
