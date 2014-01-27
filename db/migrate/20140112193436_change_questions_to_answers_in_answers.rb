class ChangeQuestionsToAnswersInAnswers < ActiveRecord::Migration
  def change
  	rename_column :answers, :question, :answer
  end
end
