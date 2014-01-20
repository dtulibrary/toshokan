class AddDocdelOrderidToOrders < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.text :docdel_order_id
      t.index :docdel_order_id
    end
  end
end
