class CreateQueries < ActiveRecord::Migration
  def change
    create_table :queries do |t|
      t.text       :name
      t.text       :query_string
      t.boolean    :enabled, default: false
      t.integer    :latest_count
      t.timestamp  :run_at
      t.timestamps
    end
  end
end
