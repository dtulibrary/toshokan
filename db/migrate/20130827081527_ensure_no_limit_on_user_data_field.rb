class EnsureNoLimitOnUserDataField < ActiveRecord::Migration
  def up
    change_column :users, :user_data, :text, :limit => nil
  end

  def down
  end
end
