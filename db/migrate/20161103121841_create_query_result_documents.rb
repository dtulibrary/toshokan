class CreateQueryResultDocuments < ActiveRecord::Migration
  def change
    create_table :query_result_documents do |t|
      t.text       :document_id
      t.text       :document
      t.text       :duplicate
      t.boolean    :rejected, default: false
      t.references :query
      t.timestamps
    end
  end
end
