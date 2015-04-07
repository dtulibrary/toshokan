class AddPhysicalDeliveryToAssistanceRequests < ActiveRecord::Migration
  def change
    change_table :assistance_requests do |t|
      t.text :physical_delivery
    end
  end
end
