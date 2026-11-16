module Api
  class MonthlyComparisonsController < ApplicationController

    REQUEST_PARAMS = %w[store_id category_id channel].freeze

    def show
      request = Reports::MonthlyComparisonRequest.new(request_parameters)
      result = Reports::MonthlyComparison.new(request: request).call

      render json: Reports::MonthlyComparisonSerializer.new(result).as_json
    end

    private

    # object rather than silently coercing arrays/hashes into strings.
    def request_parameters
      REQUEST_PARAMS.each_with_object({}) do |key, result|
        result[key] = params[key] if params.key?(key)
      end
    end

  end
end
