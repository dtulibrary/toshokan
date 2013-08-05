class UpdateSearchHistory < ActiveRecord::Migration
  def up
    change_column :searches, :saved, :boolean, :default => false
    change_column :searches, :alerted, :boolean, :default => false
  end

  def down
    change_column :searches, :saved, :boolean, :default => nil
    change_column :searches, :alerted, :boolean, :default => nil
  end
end
