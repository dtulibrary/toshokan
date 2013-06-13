class FixOrdersTypeProblems < ActiveRecord::Migration
  def up
    change_table :orders do |t|
      t.remove :open_url
      t.text :open_url
    end
  end

  def down
    change_table :orders do |t|
      t.remove :open_url
      t.string :open_url
    end
  end
end
