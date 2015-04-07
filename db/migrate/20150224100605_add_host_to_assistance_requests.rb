class AddHostToAssistanceRequests < ActiveRecord::Migration
  def change
    change_table :assistance_requests do |t|
      t.text :host_title
      t.text :host_isxn
      t.text :host_volume
      t.text :host_issue
      t.text :host_year
      t.text :host_pages
      t.text :host_series
    end
  end
end
