class AddAssistanceRequestToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :assistance_request_id, :integer
  end

  def down
    remove_column :orders, :assistance_request_id
  end
end
