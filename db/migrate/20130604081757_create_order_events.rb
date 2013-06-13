class CreateOrderEvents < ActiveRecord::Migration
  def change
    create_table :order_events do |t|
      t.references :order
      t.string :name
      t.string :data
      t.timestamp :created_at
    end

    add_index :order_events, :name
  end
end
