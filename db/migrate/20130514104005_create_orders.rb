class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :uuid
      t.string :open_url
      t.string :supplier
      t.integer :price
      t.integer :vat
      t.string :currency
      t.string :email
      t.string :mobile
      t.string :customer_ref
      t.string :dibs_transaction_id
      t.string :payment_status
      t.string :delivery_status
      t.timestamp :payed_at
      t.timestamp :delivered_at
      t.timestamps

      t.references :user
    end

    add_index :orders, :user_id
    add_index :orders, :uuid
  end
end
