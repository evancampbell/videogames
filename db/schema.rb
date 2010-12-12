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

ActiveRecord::Schema.define(:version => 20101207215441) do

  create_table "associations", :force => true do |t|
    t.integer  "game_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "relevance",  :default => 0
  end

  add_index "associations", ["game_id"], :name => "index_associations_on_game_id"
  add_index "associations", ["tag_id"], :name => "index_associations_on_tag_id"

  create_table "games", :force => true do |t|
    t.string   "name"
    t.integer  "year"
    t.integer  "rating"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "type_of",     :default => 0
    t.integer  "parent",      :default => 0
  end

  create_table "links", :force => true do |t|
    t.string   "url"
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent"
    t.integer  "type_id"
    t.integer  "children",    :default => 0
  end

  create_table "types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "value"
  end

end
