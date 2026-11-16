require "json"

fixture_path = Rails.root.join("db/data/monthly_sales.json")
payload = JSON.parse(File.read(fixture_path))

ActiveRecord::Base.transaction do
  store_ids = payload.fetch("stores").map { |store| store.fetch("id") }
  MonthlySale.where(store_id: store_ids).delete_all

  payload.fetch("stores").each do |store_data|
    Store.find_or_initialize_by(id: store_data.fetch("id")).update!(
      name: store_data.fetch("name"),
      reporting_through: Date.strptime(store_data.fetch("reporting_through"), "%Y-%m")
    )
  end

  payload.fetch("monthly_sales").each do |row|
    MonthlySale.create!(
      store_id: row.fetch("store_id"),
      month: Date.strptime(row.fetch("month"), "%Y-%m"),
      category_id: row.fetch("category_id"),
      channel: row.fetch("channel"),
      sales_ex_tax: row.fetch("sales_ex_tax"),
      gross_profit_ex_tax: row.fetch("gross_profit_ex_tax"),
      orders: row.fetch("orders"),
      returns: row.fetch("returns")
    )
  end
end

puts "Seeded challenge demo data for #{store_ids.length} store(s)."
puts "NOTE: this is synthetic sample data, not CirclePOS production or challenge-source data."
