class Store < ApplicationRecord
  self.primary_key = :id

  has_many :monthly_sales, dependent: :delete_all

  validates :id, :name, :reporting_through, presence: true

  def latest_month
    reporting_through&.beginning_of_month
  end
end
