class AddFilterFlagToQueries < ActiveRecord::Migration
  def change
    add_column :queries, :filter, :boolean, null: false, default: false
  end
end
