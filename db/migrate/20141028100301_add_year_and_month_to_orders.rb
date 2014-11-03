class AddYearAndMonthToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :created_year,  :text
    add_column :orders, :created_month, :text
    add_column :orders, :delivered_year,  :text
    add_column :orders, :delivered_month, :text
  end

  def down
    remove_column :orders, :created_year
    remove_column :orders, :delivered_year
    remove_column :orders, :created_month
    remove_column :orders, :delivered_month
  end
end
