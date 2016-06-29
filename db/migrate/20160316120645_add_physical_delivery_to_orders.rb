class AddPhysicalDeliveryToOrders < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.text :physical_delivery
    end
   end
end
