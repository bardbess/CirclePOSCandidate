module Reports
  class MonthlyComparisonRequest
    include ActiveModel::Validations

    MONTHS = 24 # hard requirement

    attr_reader :store_id, :months, :category_id, :channel

    validates_presence_of :store_id

    def initialize(params)
      hash_params = params.to_h.symbolize_keys.select { |_, v| v.present? }

      @store_id = hash_params[:store_id]
      @months = MONTHS
      @category_id = hash_params[:category_id]
      @channel = hash_params[:channel]
    end
  end
end
