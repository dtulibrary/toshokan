class AddMaskedCardNumberToOrders < ActiveRecord::Migration
  def change
    change_table :orders do |t|
      t.string :masked_card_number
    end
  end
end
