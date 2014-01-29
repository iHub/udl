class AddQuestionIdAndQuestionToAnswerLogs < ActiveRecord::Migration
  def change
    add_column :answer_logs, :question_id, :integer
    add_column :answer_logs, :question, :string

    add_index  :answer_logs, :question_id
  end


end
