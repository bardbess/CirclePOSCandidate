class Store < ApplicationRecord
  self.primary_key = :id

  has_many :monthly_sales, dependent: :delete_all

  validates :id, :name, :reporting_through, presence: true

end
