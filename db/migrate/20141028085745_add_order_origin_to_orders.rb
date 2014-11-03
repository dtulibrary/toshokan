class AddOrderOriginToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :origin, :text
  end

  def down
    remove_column :order, :origin
  end
end
