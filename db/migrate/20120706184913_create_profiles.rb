class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.integer :user_id
      t.string  :kind
      t.boolean :active
      t.string :org_id
      t.string :identifier
      t.string :email

      t.timestamps
    end
    add_index :profiles, :active
    add_index :profiles, :org_id
  end
end
