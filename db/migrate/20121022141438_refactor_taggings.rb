class RefactorTaggings < ActiveRecord::Migration
  def change
    drop_table :tags
    drop_table :taggings
    drop_table :solr_document_pointers

    create_table :tags do |t|
      t.string :name
      t.references :user
      t.boolean :shared
      t.timestamps
    end
    add_index :tags, :user_id
    add_index :tags, :shared
    add_index :tags, [:name, :user_id], :unique => true

    create_table :taggings do |t|
      t.references :tag
      t.string :solr_id
      t.timestamps
    end
    add_index :taggings, :tag_id
    add_index :taggings, [:tag_id,:solr_id], :unique=>true

    create_table :subscriptions do |t|
      t.references :user
      t.references :tag
    end
    add_index :subscriptions, :user_id
    add_index :subscriptions, [:user_id, :tag_id], :unique => true
  end
end
