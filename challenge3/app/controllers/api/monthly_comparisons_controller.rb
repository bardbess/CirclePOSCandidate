module Api
  class MonthlyComparisonsController < ApplicationController

    REQUEST_PARAMS = %w[store_id category_id channel].freeze

    def show
      inquiry = Reports::MonthlyComparisonRequest.new(request_parameters)

      if inquiry.valid?
        result = Reports::MonthlyComparison.new(request: inquiry).call
        render json: Reports::MonthlyComparisonSerializer.new(result).as_json

      else
        error = inquiry.errors.full_messages.to_sentence
        render json: { error: { code: 'bad_request', message: error } }, status: :bad_request
      end
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
