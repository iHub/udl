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

ActiveRecord::Schema.define(version: 20141103081529) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "annotations", force: true do |t|
    t.integer  "user_id"
    t.integer  "scrape_session_id"
    t.integer  "question_id"
    t.integer  "answer_id"
    t.integer  "post_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "annotations", ["answer_id"], name: "index_annotations_on_answer_id", using: :btree
  add_index "annotations", ["post_id"], name: "index_annotations_on_post_id", using: :btree
  add_index "annotations", ["question_id"], name: "index_annotations_on_question_id", using: :btree
  add_index "annotations", ["scrape_session_id"], name: "index_annotations_on_scrape_session_id", using: :btree
  add_index "annotations", ["user_id"], name: "index_annotations_on_user_id", using: :btree

  create_table "annotators", force: true do |t|
    t.integer  "user_id"
    t.integer  "scrape_session_id"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "annotators", ["scrape_session_id"], name: "index_annotators_on_scrape_session_id", using: :btree
  add_index "annotators", ["user_id"], name: "index_annotators_on_user_id", using: :btree

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

  add_index "answer_logs", ["answer_id"], name: "index_answer_logs_on_answer_id", using: :btree
  add_index "answer_logs", ["question_id"], name: "index_answer_logs_on_question_id", using: :btree
  add_index "answer_logs", ["scrape_session_id"], name: "index_answer_logs_on_scrape_session_id", using: :btree
  add_index "answer_logs", ["user_id"], name: "index_answer_logs_on_user_id", using: :btree

  create_table "answers", force: true do |t|
    t.integer  "question_id"
    t.string   "answer"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "answers", ["question_id"], name: "index_answers_on_question_id", using: :btree

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

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "disqus_answers", force: true do |t|
    t.integer  "disqus_forum_comment_id"
    t.integer  "answer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "disqus_answers", ["answer_id"], name: "index_disqus_answers_on_answer_id", using: :btree
  add_index "disqus_answers", ["disqus_forum_comment_id"], name: "index_disqus_answers_on_disqus_forum_comment_id", using: :btree

  create_table "disqus_forum_comments", force: true do |t|
    t.integer  "disqus_forum_id"
    t.string   "points"
    t.string   "parent"
    t.string   "is_approved"
    t.string   "author_about"
    t.string   "author_username"
    t.string   "author_name"
    t.string   "author_url"
    t.string   "author_is_following"
    t.string   "author_is_follwed_by"
    t.string   "author_profile_url"
    t.string   "author_reputation"
    t.string   "author_location"
    t.string   "author_id"
    t.string   "author_disliked"
    t.string   "author_created_at"
    t.string   "forum_id"
    t.string   "forum_thread"
    t.string   "forum_num_reports"
    t.string   "forum_likes"
    t.string   "forum_is_edited"
    t.string   "forum_is_spam"
    t.string   "forum_is_highlighted"
    t.string   "forum_user_score"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "author_raw_message"
    t.text     "author_message"
    t.text     "forum_message"
    t.integer  "scrape_session_id"
    t.string   "forum_name"
  end

  add_index "disqus_forum_comments", ["disqus_forum_id"], name: "index_disqus_forum_comments_on_disqus_forum_id", using: :btree
  add_index "disqus_forum_comments", ["scrape_session_id"], name: "index_disqus_forum_comments_on_scrape_session_id", using: :btree

  create_table "disqus_forums", force: true do |t|
    t.integer  "user_id"
    t.integer  "scrape_session_id"
    t.string   "forum_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "disqus_forums", ["scrape_session_id"], name: "index_disqus_forums_on_scrape_session_id", using: :btree
  add_index "disqus_forums", ["user_id"], name: "index_disqus_forums_on_user_id", using: :btree

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

  add_index "fb_comments", ["comment_id"], name: "index_fb_comments_on_comment_id", using: :btree
  add_index "fb_comments", ["fb_post_id"], name: "index_fb_comments_on_fb_post_id", using: :btree

  create_table "fb_posts", force: true do |t|
    t.string   "fb_post_id"
    t.text     "message"
    t.string   "fb_page_id"
    t.datetime "created_time"
    t.integer  "scrape_page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fb_posts", ["fb_page_id"], name: "index_fb_posts_on_fb_page_id", using: :btree
  add_index "fb_posts", ["fb_post_id"], name: "index_fb_posts_on_fb_post_id", using: :btree
  add_index "fb_posts", ["scrape_page_id"], name: "index_fb_posts_on_scrape_page_id", using: :btree

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

  add_index "question_logs", ["question_id"], name: "index_question_logs_on_question_id", using: :btree
  add_index "question_logs", ["scrape_session_id"], name: "index_question_logs_on_scrape_session_id", using: :btree
  add_index "question_logs", ["user_id"], name: "index_question_logs_on_user_id", using: :btree

  create_table "questions", force: true do |t|
    t.integer  "scrape_session_id"
    t.string   "question"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "questions", ["scrape_session_id"], name: "index_questions_on_scrape_session_id", using: :btree

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

  add_index "regular_scrape_logs", ["scrape_page_id"], name: "index_regular_scrape_logs_on_scrape_page_id", using: :btree
  add_index "regular_scrape_logs", ["scrape_session_id"], name: "index_regular_scrape_logs_on_scrape_session_id", using: :btree

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

  add_index "scrape_page_logs", ["scrape_page_id"], name: "index_scrape_page_logs_on_scrape_page_id", using: :btree
  add_index "scrape_page_logs", ["scrape_session_id"], name: "index_scrape_page_logs_on_scrape_session_id", using: :btree
  add_index "scrape_page_logs", ["user_id"], name: "index_scrape_page_logs_on_user_id", using: :btree

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
  end

  add_index "scrape_pages", ["fb_page_id"], name: "index_scrape_pages_on_fb_page_id", using: :btree
  add_index "scrape_pages", ["scrape_session_id"], name: "index_scrape_pages_on_scrape_session_id", using: :btree

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

  add_index "scrape_session_logs", ["scrape_session_id"], name: "index_scrape_session_logs_on_scrape_session_id", using: :btree
  add_index "scrape_session_logs", ["user_id"], name: "index_scrape_session_logs_on_user_id", using: :btree

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
  end

  add_index "scrape_sessions", ["allow_page_override"], name: "index_scrape_sessions_on_allow_page_override", using: :btree
  add_index "scrape_sessions", ["user_id"], name: "index_scrape_sessions_on_user_id", using: :btree

  create_table "tagger_answers", force: true do |t|
    t.integer  "question_id"
    t.string   "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tagger_answers", ["question_id"], name: "index_tagger_answers_on_question_id", using: :btree

  create_table "tagger_questions", force: true do |t|
    t.string   "content"
    t.integer  "forum_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "scrape_session_id"
  end

  add_index "tagger_questions", ["forum_id"], name: "index_tagger_questions_on_forum_id", using: :btree
  add_index "tagger_questions", ["scrape_session_id"], name: "index_tagger_questions_on_scrape_session_id", using: :btree

  create_table "tagger_tagger_posts", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "tweet_id"
  end

  add_index "tagger_tagger_posts", ["tweet_id"], name: "index_tagger_tagger_posts_on_tweet_id", using: :btree
  add_index "tagger_tagger_posts", ["user_id"], name: "index_tagger_tagger_posts_on_user_id", using: :btree

  create_table "tweet_answers", force: true do |t|
    t.integer  "tweet_id"
    t.integer  "answer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "disqus_forum_comment_id"
  end

  add_index "tweet_answers", ["answer_id"], name: "index_tweet_answers_on_answer_id", using: :btree
  add_index "tweet_answers", ["disqus_forum_comment_id"], name: "index_tweet_answers_on_disqus_forum_comment_id", using: :btree
  add_index "tweet_answers", ["tweet_id"], name: "index_tweet_answers_on_tweet_id", using: :btree

  create_table "tweet_taggers", force: true do |t|
    t.integer  "tweet_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tweet_taggers", ["tweet_id"], name: "index_tweet_taggers_on_tweet_id", using: :btree
  add_index "tweet_taggers", ["user_id"], name: "index_tweet_taggers_on_user_id", using: :btree

  create_table "twitter_parser_accounts", force: true do |t|
    t.string   "name"
    t.string   "twitter_user_id"
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "scrape_session_id"
  end

  add_index "twitter_parser_accounts", ["scrape_session_id"], name: "index_twitter_parser_accounts_on_scrape_session_id", using: :btree

  create_table "twitter_parser_terms", force: true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "channel"
    t.integer  "scrape_session_id"
  end

  add_index "twitter_parser_terms", ["scrape_session_id"], name: "index_twitter_parser_terms_on_scrape_session_id", using: :btree

  create_table "twitter_parser_tweets", force: true do |t|
    t.string   "tweet_id"
    t.string   "text"
    t.string   "tweet_user"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "tweet_created_at"
    t.string   "source"
    t.string   "truncated"
    t.string   "in_reply_to_status_id"
    t.string   "in_reply_to_status_id_str"
    t.string   "in_reply_to_user_id"
    t.string   "in_reply_to_user_id_str"
    t.string   "in_reply_to_screen_name"
    t.string   "user"
    t.string   "tweet_user_id"
    t.string   "tweet_user_id_str"
    t.string   "tweet_user_name"
    t.string   "tweet_user_screen_name"
    t.string   "location"
    t.string   "url"
    t.string   "expanded_url"
    t.string   "entities_url"
    t.string   "description"
    t.boolean  "protected",                 default: false
    t.string   "followers_count"
    t.string   "friends_count"
    t.string   "listed_count"
    t.string   "tweet_user_created_at"
    t.string   "favourites_count"
    t.string   "utc_offset"
    t.string   "time_zone"
    t.boolean  "geo_enabled",               default: false
    t.boolean  "verified",                  default: false
    t.string   "statuses_count"
    t.boolean  "contributors_enabled",      default: false
    t.boolean  "is_translator",             default: false
    t.boolean  "is_translation_enabled",    default: false
    t.string   "following"
    t.string   "follow_request_sent"
    t.string   "notifications"
    t.string   "geo"
    t.string   "coordinates"
    t.string   "place"
    t.string   "contributors"
    t.string   "retweet_count"
    t.string   "favorite_count"
    t.string   "entities"
    t.string   "hashtags"
    t.string   "symbols"
    t.string   "urls"
    t.string   "user_mentions"
    t.boolean  "favorited",                 default: false
    t.boolean  "retweeted",                 default: false
    t.boolean  "possibly_sensitive",        default: false
    t.string   "lang"
    t.integer  "scrape_session_id"
  end

  add_index "twitter_parser_tweets", ["scrape_session_id"], name: "index_twitter_parser_tweets_on_scrape_session_id", using: :btree

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

  add_index "user_logs", ["user_id"], name: "index_user_logs_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "firstname"
    t.string   "lastname"
    t.string   "email"
    t.string   "role"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

end
