class CreateRedmineSynchronizations < ActiveRecord::Migration
  def change
    create_table :redmine_synchronizations do |t|
      t.datetime :runtime
      t.datetime :latest_issue_update_time
    end
  end
end
