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

ActiveRecord::Schema.define(:version => 3) do

  create_table "bits", :force => true do |t|
    t.string  "label"
    t.string  "xpath",                            :null => false
    t.boolean "generalize",     :default => true
    t.integer "rip_id",                           :null => false
    t.integer "position"
    t.string  "select_indizes"
  end

  create_table "form_fields", :force => true do |t|
    t.string  "type",                              :null => false
    t.string  "name",                              :null => false
    t.string  "value"
    t.integer "navi_action_id",                    :null => false
    t.string  "options"
    t.boolean "required",       :default => false
    t.boolean "constant",       :default => false
  end

  create_table "messages", :force => true do |t|
    t.string "key",     :null => false
    t.text   "content"
  end

  create_table "navi_actions", :force => true do |t|
    t.string  "type"
    t.integer "rip_id",    :null => false
    t.integer "position"
    t.string  "link_text"
  end

  create_table "rips", :force => true do |t|
    t.string  "name",        :null => false
    t.text    "description"
    t.string  "start_page",  :null => false
    t.integer "parent_id"
    t.boolean "current"
    t.integer "revision"
    t.date    "created_at"
    t.integer "next_pages"
    t.string  "next_link"
    t.integer "position"
  end

end
