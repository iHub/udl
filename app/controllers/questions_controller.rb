class QuestionsController < ApplicationController

  def index
    @scrape_session = ScrapeSession.find(params[:scrape_session_id])
    @questions = @scrape_session.questions
  end

  def edit
    @scrape_session = ScrapeSession.find(params[:scrape_session_id])
  	@question = @scrape_session.questions.find(params[:id])
  end

  def new
    @scrape_session = ScrapeSession.find(params[:scrape_session_id])
  	@question = @scrape_session.questions.build
  end

  def create
    @scrape_session = ScrapeSession.find(params[:scrape_session_id])
  	@question = @scrape_session.questions.build(question_params)
  	if @question.save
  		flash[:success] = "Question created!"
      redirect_to scrape_session_questions_path
  	else
  		render 'new'
  	end
  end

  def update    
    @scrape_session = ScrapeSession.find(params[:scrape_session_id])
    if @question.update_attributes(question_params)
      flash[:success] = "Your Question has been updated."
      redirect_to scrape_session_questions_path
    else
      render edit_scrape_session_question_path(@question)
    end
  end

  def show
    @scrape_session = ScrapeSession.find(params[:scrape_session_id])
  	@question = @scrape_session.questions.find(params[:id])
    @answers = @question.answers
  end

  def destroy
    @scrape_session = ScrapeSession.find(params[:scrape_session_id])
  	question = @scrape_session.questions.find(params[:id]).destroy 
    flash[:success] = "Question Deleted!"
    redirect_to scrape_session_questions_path
  end

  private

    def question_params
      params.require(:question).permit(:question, :description)
    end

end
