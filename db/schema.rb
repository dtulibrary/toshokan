# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131111123049) do

  create_table "assistance_requests", :force => true do |t|
    t.string   "type"
    t.integer  "user_id"
    t.text     "article_title"
    t.text     "article_author"
    t.text     "article_doi"
    t.text     "journal_title"
    t.text     "journal_issn"
    t.text     "journal_volume"
    t.text     "journal_issue"
    t.text     "journal_year"
    t.text     "journal_pages"
    t.text     "conference_title"
    t.text     "conference_location"
    t.text     "conference_year"
    t.text     "book_title"
    t.text     "book_author"
    t.text     "book_edition"
    t.text     "book_doi"
    t.text     "book_isbn"
    t.text     "book_year"
    t.text     "notes"
    t.text     "email"
    t.text     "pickup_location"
    t.text     "physical_location"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.text     "conference_isxn"
    t.text     "conference_pages"
    t.text     "book_publisher"
  end

  create_table "bookmarks", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.string   "document_id"
    t.string   "title"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "user_type"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "order_events", :force => true do |t|
    t.integer  "order_id"
    t.string   "name"
    t.text     "data"
    t.datetime "created_at"
  end

  add_index "order_events", ["name"], :name => "index_order_events_on_name"

  create_table "orders", :force => true do |t|
    t.string   "uuid"
    t.string   "supplier"
    t.integer  "price"
    t.integer  "vat"
    t.string   "currency"
    t.string   "email"
    t.string   "mobile"
    t.string   "customer_ref"
    t.string   "dibs_transaction_id"
    t.string   "payment_status"
    t.string   "delivery_status"
    t.datetime "payed_at"
    t.datetime "delivered_at"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "user_id"
    t.text     "open_url"
    t.string   "masked_card_number"
  end

  add_index "orders", ["user_id"], :name => "index_orders_on_user_id"
  add_index "orders", ["uuid"], :name => "index_orders_on_uuid"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "code"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "searches", :force => true do |t|
    t.text     "query_params"
    t.integer  "user_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.string   "user_type"
    t.string   "title"
    t.boolean  "saved",        :default => false
    t.boolean  "alerted",      :default => false
  end

  add_index "searches", ["user_id"], :name => "index_searches_on_user_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "subscriptions", :force => true do |t|
    t.integer "user_id"
    t.integer "tag_id"
  end

  add_index "subscriptions", ["user_id", "tag_id"], :name => "index_subscriptions_on_user_id_and_tag_id", :unique => true
  add_index "subscriptions", ["user_id"], :name => "index_subscriptions_on_user_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "bookmark_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "taggings", ["bookmark_id"], :name => "index_taggings_on_bookmark_id"
  add_index "taggings", ["tag_id", "bookmark_id"], :name => "index_taggings_on_tag_id_and_bookmark_id", :unique => true
  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.boolean  "shared"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "tags", ["name", "user_id"], :name => "index_tags_on_name_and_user_id", :unique => true
  add_index "tags", ["shared"], :name => "index_tags_on_shared"
  add_index "tags", ["user_id"], :name => "index_tags_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "provider"
    t.string   "identifier"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.text     "user_data"
  end

  add_index "users", ["identifier"], :name => "index_users_on_identifier"
  add_index "users", ["provider", "identifier"], :name => "index_users_on_provider_and_identifier", :unique => true

end
