# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_11_16_000002) do
  create_table "monthly_sales", force: :cascade do |t|
    t.string "store_id", null: false
    t.date "month", null: false
    t.string "category_id", null: false
    t.string "channel", null: false
    t.decimal "sales_ex_tax", precision: 15, scale: 2, null: false
    t.decimal "gross_profit_ex_tax", precision: 15, scale: 2, null: false
    t.integer "orders", default: 0, null: false
    t.integer "returns", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id", "category_id", "channel", "month"], name: "index_monthly_sales_for_report_filters"
    t.index ["store_id", "month"], name: "index_monthly_sales_on_store_id_and_month"
  end

  create_table "stores", id: :string, force: :cascade do |t|
    t.string "name", null: false
    t.date "reporting_through", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "monthly_sales", "stores"
end
