class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :provider
      t.string :identifier
      t.string :firstname
      t.string :lastname
      t.string :email
      t.string :username

      t.timestamps
    end

    add_index :users, :identifier
    add_index :users, :username
    add_index :users, [:provider, :identifier], :unique => true
  end
end
