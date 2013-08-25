class ChangeUserDataToTypeText < ActiveRecord::Migration
  def up
    change_column :users, :user_data, :text
  end
  def down
    change_column :users, :user_data, :string
  end
end
