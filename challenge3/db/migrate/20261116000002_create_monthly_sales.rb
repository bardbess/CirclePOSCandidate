class CreateMonthlySales < ActiveRecord::Migration[8.0]
  def change
    create_table :monthly_sales do |t|
      t.string :store_id, null: false
      t.date :month, null: false
      t.string :category_id, null: false
      t.string :channel, null: false
      t.decimal :sales_ex_tax, precision: 15, scale: 2, null: false
      t.decimal :gross_profit_ex_tax, precision: 15, scale: 2, null: false
      t.integer :orders, null: false, default: 0
      t.integer :returns, null: false, default: 0
      t.timestamps
    end

    add_foreign_key :monthly_sales, :stores, column: :store_id, primary_key: :id
    add_index :monthly_sales, [:store_id, :month]
    add_index :monthly_sales, [:store_id, :category_id, :channel, :month],
              name: "index_monthly_sales_for_report_filters"
  end
end
