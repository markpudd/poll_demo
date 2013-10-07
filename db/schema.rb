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

ActiveRecord::Schema.define(:version => 20130929232558) do

  create_table "answers", :force => true do |t|
    t.string   "answer_text"
    t.integer  "poll_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "answers", ["poll_id"], :name => "index_answers_on_poll_id"

  create_table "players", :force => true do |t|
    t.string   "name"
    t.string   "gl_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "polls", :force => true do |t|
    t.string   "question"
    t.string   "sfid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "votes", :force => true do |t|
    t.integer  "answer_id"
    t.integer  "player_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "votes", ["answer_id"], :name => "index_votes_on_answer_id"
  add_index "votes", ["player_id"], :name => "index_votes_on_player_id"

end
