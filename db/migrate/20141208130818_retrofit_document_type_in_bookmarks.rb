class RetrofitDocumentTypeInBookmarks < ActiveRecord::Migration
  def up
    execute "update bookmarks set document_type = 'SolrDocument' where document_type is null"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
