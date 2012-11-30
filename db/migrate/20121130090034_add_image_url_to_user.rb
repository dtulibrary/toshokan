class AddImageUrlToUser < ActiveRecord::Migration
  def change
    add_column :users, :image_url, :string, :null => true, :default => nil
  end
end
