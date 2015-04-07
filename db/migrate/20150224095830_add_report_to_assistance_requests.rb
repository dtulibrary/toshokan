class AddReportToAssistanceRequests < ActiveRecord::Migration
  def change
    change_table :assistance_requests do |t|
      t.text :report_title
      t.text :report_author
      t.text :report_publisher
      t.text :report_doi
      t.text :report_number
    end
  end
end
