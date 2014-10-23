class CreateProgresses < ActiveRecord::Migration
  def change
    create_table :progresses do |t|
      t.string :name
      t.float :start
      t.float :current
      t.float :end
      t.boolean :stop
      t.boolean :finished

      t.timestamps
    end
    add_index :progresses, :name
  end
end
