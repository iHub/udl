class CreateAnswerLogs < ActiveRecord::Migration
  def change
    create_table :answer_logs do |t|
      t.integer  :scrape_session_id
      t.integer  :answer_id
      t.string   :answer
      t.datetime :event_time
      t.integer  :user_id
      t.string   :username
      t.string   :event_type

      t.timestamps
    end

    add_index  :answer_logs, :user_id
    add_index  :answer_logs, :answer_id
    add_index  :answer_logs, :scrape_session_id
  end
end
