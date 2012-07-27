class AddCodeToRole < ActiveRecord::Migration
  def change
    add_column :roles, :code, :string
  end
end
