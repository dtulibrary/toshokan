class AddSupplierOrderidToOrders < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.text :supplier_order_id
      t.index :supplier_order_id
    end
  end
end
