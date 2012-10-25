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

ActiveRecord::Schema.define(:version => 20121130090034) do

  create_table "bookmarks", :force => true do |t|
    t.integer  "user_id",     :null => false
    t.string   "document_id"
    t.string   "title"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "user_type"
  end

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "kind"
    t.boolean  "active"
    t.string   "org_id"
    t.string   "identifier"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "profiles", ["active"], :name => "index_profiles_on_active"
  add_index "profiles", ["org_id"], :name => "index_profiles_on_org_id"

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
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "user_type"
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
    t.string   "solr_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "taggings", ["tag_id", "solr_id"], :name => "index_taggings_on_tag_id_and_solr_id", :unique => true
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
    t.string   "firstname"
    t.string   "lastname"
    t.string   "email"
    t.string   "username"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "image_url"
  end

  add_index "users", ["identifier"], :name => "index_users_on_identifier"
  add_index "users", ["provider", "identifier"], :name => "index_users_on_provider_and_identifier", :unique => true
  add_index "users", ["username"], :name => "index_users_on_username"

end
