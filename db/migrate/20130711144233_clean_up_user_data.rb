class CleanUpUserData < ActiveRecord::Migration
  def up
    drop_table :profiles

    remove_column :users, :firstname
    remove_column :users, :lastname
    remove_column :users, :username
    remove_column :users, :image_url

    add_column    :users, :user_data, :string, :null => true
  end

  def down
    create_table :profiles do |t|
      t.integer :user_id
      t.string  :kind
      t.boolean :active
      t.string  :org_id
      t.string  :identifier
      t.string  :email

      t.timestamps
    end
    add_index :profiles, :active
    add_index :profiles, :org_id

    add_column :users, :firstname, :string, :null => true, :default => nil
    add_column :users, :lastname,  :string, :null => true, :default => nil
    add_column :users, :username,  :string, :null => true, :default => nil
    add_column :users, :image_url, :string, :null => true, :default => nil

    remove_column :users, :user_data
  end
end
