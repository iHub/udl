class CreateQuestionLogs < ActiveRecord::Migration
  def change
    create_table :question_logs do |t|
      t.integer   :scrape_session_id
      t.integer   :question_id
      t.string    :question
      t.datetime  :event_time
      t.integer   :user_id
      t.string    :username
      t.string    :event_type

      t.timestamps
    end

    add_index  :question_logs, :user_id
    add_index  :question_logs, :question_id
    add_index  :question_logs, :scrape_session_id

  end
end
