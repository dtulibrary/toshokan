class ChangeOrdersForNewFacets < ActiveRecord::Migration
  def up
    add_column :orders, :user_type, :text
  end

  def down
    remove_column :order, :user_type
  end
end
