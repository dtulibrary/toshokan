class CreateSolrDocumentPointers < ActiveRecord::Migration
  def change
    create_table :solr_document_pointers do |t|
      t.string :solr_id

      t.timestamps
    end
  end
end
