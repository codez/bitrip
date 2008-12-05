# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 4) do

  create_table "bits", :force => true do |t|
    t.string  "label"
    t.string  "xpath",                            :null => false
    t.boolean "generalize",     :default => true
    t.integer "rip_id",                           :null => false
    t.integer "position"
    t.string  "select_indizes"
  end

  add_index "bits", ["rip_id"], :name => "index_bits_on_rip_id"

  create_table "form_fields", :force => true do |t|
    t.string  "type",                              :null => false
    t.string  "name",                              :null => false
    t.string  "value"
    t.integer "navi_action_id",                    :null => false
    t.string  "options"
    t.boolean "required",       :default => false
    t.boolean "constant",       :default => false
  end

  add_index "form_fields", ["navi_action_id"], :name => "index_form_fields_on_navi_action_id"

  create_table "messages", :force => true do |t|
    t.string  "key",      :null => false
    t.text    "content"
    t.string  "context"
    t.integer "position"
  end

  add_index "messages", ["key"], :name => "index_messages_on_key", :unique => true

  create_table "navi_actions", :force => true do |t|
    t.string  "type"
    t.integer "rip_id",    :null => false
    t.integer "position"
    t.string  "link_text"
  end

  add_index "navi_actions", ["rip_id"], :name => "index_navi_actions_on_rip_id"

  create_table "rips", :force => true do |t|
    t.string  "name",        :null => false
    t.text    "description"
    t.string  "start_page"
    t.integer "parent_id"
    t.boolean "current"
    t.integer "revision"
    t.date    "created_at"
    t.integer "next_pages"
    t.string  "next_link"
    t.integer "position"
  end

  add_index "rips", ["current", "name"], :name => "index_rips_on_name_and_current"

end
