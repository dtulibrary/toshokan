class AddToSearchHistory < ActiveRecord::Migration
  def up
    add_column :searches, :title, :string
    add_column :searches, :saved, :boolean
    add_column :searches, :alerted, :boolean
  end

  def down
    drop_column :searches, :title
    drop_column :searches, :saved
    drop_column :searches, :alerted
  end
end
