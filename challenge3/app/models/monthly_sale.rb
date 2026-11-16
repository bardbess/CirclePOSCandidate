class MonthlySale < ApplicationRecord
  belongs_to :store, primary_key: :id

  validates :month, :category_id, :channel, presence: true
  validates :sales_ex_tax, :gross_profit_ex_tax, numericality: true
  validates :orders, :returns, numericality: { only_integer: true }
end
