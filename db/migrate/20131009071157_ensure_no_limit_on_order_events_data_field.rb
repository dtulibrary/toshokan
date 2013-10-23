class EnsureNoLimitOnOrderEventsDataField < ActiveRecord::Migration
  def up
    change_column :order_events, :data, :text, :limit => nil
  end

  def down
  end
end
