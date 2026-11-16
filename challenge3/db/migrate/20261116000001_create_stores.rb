class CreateStores < ActiveRecord::Migration[8.0]
  def change
    create_table :stores, id: :string do |t|
      t.string :name, null: false
      t.date :reporting_through, null: false
      t.timestamps
    end
  end
end
