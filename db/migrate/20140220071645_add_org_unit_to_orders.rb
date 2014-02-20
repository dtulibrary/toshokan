class AddOrgUnitToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :org_unit, :text
  end

  def down
    remove_column :orders, :org_unit
  end
end
