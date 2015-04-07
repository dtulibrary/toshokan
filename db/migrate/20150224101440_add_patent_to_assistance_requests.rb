class AddPatentToAssistanceRequests < ActiveRecord::Migration
  def change
    change_table :assistance_requests do |t|
      t.text :patent_title
      t.text :patent_inventor
      t.text :patent_number
      t.text :patent_year
      t.text :patent_country
    end
  end
end
