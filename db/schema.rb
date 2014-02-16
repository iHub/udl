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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140216054759) do

  create_table "annotations", force: true do |t|
    t.integer  "user_id"
    t.integer  "scrape_session_id"
    t.integer  "question_id"
    t.integer  "answer_id"
    t.integer  "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "annotations", ["answer_id"], name: "index_annotations_on_answer_id"
  add_index "annotations", ["post_id"], name: "index_annotations_on_post_id"
  add_index "annotations", ["question_id"], name: "index_annotations_on_question_id"
  add_index "annotations", ["scrape_session_id"], name: "index_annotations_on_scrape_session_id"
  add_index "annotations", ["user_id"], name: "index_annotations_on_user_id"

  create_table "annotators", force: true do |t|
    t.integer  "user_id"
    t.integer  "scrape_session_id"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "annotators", ["scrape_session_id"], name: "index_annotators_on_scrape_session_id"
  add_index "annotators", ["user_id"], name: "index_annotators_on_user_id"

  create_table "answer_logs", force: true do |t|
    t.integer  "scrape_session_id"
    t.integer  "answer_id"
    t.string   "answer"
    t.datetime "event_time"
    t.integer  "user_id"
    t.string   "username"
    t.string   "event_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "question_id"
    t.string   "question"
  end

  add_index "answer_logs", ["answer_id"], name: "index_answer_logs_on_answer_id"
  add_index "answer_logs", ["question_id"], name: "index_answer_logs_on_question_id"
  add_index "answer_logs", ["scrape_session_id"], name: "index_answer_logs_on_scrape_session_id"
  add_index "answer_logs", ["user_id"], name: "index_answer_logs_on_user_id"

  create_table "answers", force: true do |t|
    t.integer  "question_id"
    t.string   "answer"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answers", ["question_id"], name: "index_answers_on_question_id"

  create_table "app_settings", force: true do |t|
    t.string   "app_name"
    t.string   "welcome_message"
    t.string   "fb_app_name"
    t.string   "fb_app_id"
    t.string   "fb_app_secret"
    t.string   "fb_app_access_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "fb_comments", force: true do |t|
    t.integer  "fb_post_id"
    t.string   "comment_id"
    t.string   "from_user_id"
    t.datetime "created_time"
    t.string   "from_user_name"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "parent_id"
  end

  add_index "fb_comments", ["comment_id"], name: "index_fb_comments_on_comment_id"
  add_index "fb_comments", ["fb_post_id"], name: "index_fb_comments_on_fb_post_id"

  create_table "fb_posts", force: true do |t|
    t.string   "fb_post_id"
    t.text     "message"
    t.string   "fb_page_id"
    t.datetime "created_time"
    t.integer  "scrape_page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "fb_comments_count", default: 0
  end

  add_index "fb_posts", ["fb_page_id"], name: "index_fb_posts_on_fb_page_id"
  add_index "fb_posts", ["fb_post_id"], name: "index_fb_posts_on_fb_post_id"
  add_index "fb_posts", ["scrape_page_id"], name: "index_fb_posts_on_scrape_page_id"

  create_table "question_logs", force: true do |t|
    t.integer  "scrape_session_id"
    t.integer  "question_id"
    t.string   "question"
    t.datetime "event_time"
    t.integer  "user_id"
    t.string   "username"
    t.string   "event_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "question_logs", ["question_id"], name: "index_question_logs_on_question_id"
  add_index "question_logs", ["scrape_session_id"], name: "index_question_logs_on_scrape_session_id"
  add_index "question_logs", ["user_id"], name: "index_question_logs_on_user_id"

  create_table "questions", force: true do |t|
    t.integer  "scrape_session_id"
    t.string   "question"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "questions", ["scrape_session_id"], name: "index_questions_on_scrape_session_id"

  create_table "regular_scrape_logs", force: true do |t|
    t.integer  "scrape_session_id"
    t.integer  "scrape_page_id"
    t.datetime "scrape_process_start"
    t.datetime "scrape_process_end"
    t.integer  "collected_comments"
    t.integer  "collected_posts"
    t.datetime "next_scrape_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "scrape_page_url"
  end

  add_index "regular_scrape_logs", ["scrape_page_id"], name: "index_regular_scrape_logs_on_scrape_page_id"
  add_index "regular_scrape_logs", ["scrape_session_id"], name: "index_regular_scrape_logs_on_scrape_session_id"

  create_table "scrape_page_logs", force: true do |t|
    t.integer  "user_id"
    t.string   "username"
    t.integer  "scrape_page_id"
    t.string   "page_url"
    t.integer  "scrape_session_id"
    t.string   "fb_page_id"
    t.integer  "scrape_frequency"
    t.datetime "event_time"
    t.string   "event_type"
    t.datetime "next_scrape_date"
    t.boolean  "continous_scrape"
    t.boolean  "override_session_settings"
    t.integer  "fb_posts_count"
    t.integer  "fb_comments_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scrape_page_logs", ["scrape_page_id"], name: "index_scrape_page_logs_on_scrape_page_id"
  add_index "scrape_page_logs", ["scrape_session_id"], name: "index_scrape_page_logs_on_scrape_session_id"
  add_index "scrape_page_logs", ["user_id"], name: "index_scrape_page_logs_on_user_id"

  create_table "scrape_pages", force: true do |t|
    t.string   "page_url"
    t.integer  "scrape_frequency"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "scrape_session_id"
    t.datetime "next_scrape_date"
    t.boolean  "continous_scrape"
    t.string   "fb_page_id"
    t.boolean  "override_session_settings"
    t.string   "page_type"
    t.integer  "fb_posts_count",            default: 0
  end

  add_index "scrape_pages", ["fb_page_id"], name: "index_scrape_pages_on_fb_page_id"
  add_index "scrape_pages", ["scrape_session_id"], name: "index_scrape_pages_on_scrape_session_id"

  create_table "scrape_session_logs", force: true do |t|
    t.integer  "user_id"
    t.string   "username"
    t.integer  "scrape_session_name"
    t.integer  "scrape_session_id"
    t.datetime "event_time"
    t.string   "event_type"
    t.integer  "session_scrape_frequency"
    t.datetime "session_next_scrape_date"
    t.boolean  "session_continuous_scrape"
    t.boolean  "allow_page_override"
    t.integer  "scrape_page_count"
    t.integer  "fb_posts_count"
    t.integer  "fb_comments_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scrape_session_logs", ["scrape_session_id"], name: "index_scrape_session_logs_on_scrape_session_id"
  add_index "scrape_session_logs", ["user_id"], name: "index_scrape_session_logs_on_user_id"

  create_table "scrape_sessions", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "allow_page_override"
    t.integer  "session_scrape_frequency"
    t.boolean  "session_continuous_scrape"
    t.datetime "session_next_scrape_date"
    t.integer  "scrape_pages_count",        default: 0
    t.integer  "questions_count",           default: 0
  end

  add_index "scrape_sessions", ["allow_page_override"], name: "index_scrape_sessions_on_allow_page_override"
  add_index "scrape_sessions", ["user_id"], name: "index_scrape_sessions_on_user_id"

  create_table "user_logs", force: true do |t|
    t.integer  "user_id"
    t.string   "firstname"
    t.string   "lastname"
    t.string   "email"
    t.string   "role"
    t.datetime "event_time"
    t.string   "event_type"
    t.integer  "signin_count"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_logs", ["user_id"], name: "index_user_logs_on_user_id"

  create_table "users", force: true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "email"
    t.string   "role"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.integer  "scrape_sessions_count", default: 0
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

end
