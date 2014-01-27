class AnswersController < ApplicationController

  def index
    @scrape_session = ScrapeSession.find(params[:scrape_session_id])
    @question = Question.find(params[:question_id])
    @answers = @question.answers
  end

  def edit
    @scrape_session = ScrapeSession.find(params[:scrape_session_id])
    @question = Question.find(params[:question_id])
  	@answer = @question.answers.find(params[:id])
  end

  def new
    @scrape_session = ScrapeSession.find(params[:scrape_session_id])
    @question = Question.find(params[:question_id])
  	@answer = @question.answers.build
  end

  def create
    @question = Question.find(params[:question_id])
  	@answer = @question.answers.build(answer_params)
  	if @answer.save
  		flash[:success] = "Answer created!" 
      redirect_to scrape_session_question_answers_path
  	else
  		render 'new'
  	end
  end

  def update    
    @question = Question.find(params[:question_id])
    if @answer.update_attributes(answer_params)
      flash[:success] = "Your Question has been updated."
      redirect_to scrape_session_questions_answers_path
    else
      render edit_scrape_session_question_answer_path(@answer)
    end
  end

  def show
    @scrape_session = ScrapeSession.find(params[:scrape_session_id])
    @question = Question.find(params[:question_id])
  	@answer = @question.answers.find(params[:id])
  end

  def destroy
    @question = Question.find(params[:question_id])
  	answer = @question.answers.find(params[:id]).destroy 
    flash[:success] = "Answer Deleted!"
    redirect_to scrape_session_question_answers_path
  end

  private

    def answer_params
      params.require(:answer).permit(:answer, :description)
    end

end
