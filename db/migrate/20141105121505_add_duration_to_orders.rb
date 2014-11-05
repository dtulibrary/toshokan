class AddDurationToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :duration_hours, :int
  end

  def down
    remove_column :orders, :duration_hours
  end
end
