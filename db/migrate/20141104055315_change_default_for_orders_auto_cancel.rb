class ChangeDefaultForOrdersAutoCancel < ActiveRecord::Migration
  def up
    change_column_default :assistance_requests, :auto_cancel, nil
  end

  def down
    change_column_default :assistance_requests, :auto_cancel, 'never'
  end
end
