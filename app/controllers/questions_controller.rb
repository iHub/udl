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
      log_question_event @question, "create"
  		flash[:success] = "Question created!"
      redirect_to scrape_session_questions_path
  	else
  		render 'new'
  	end
  end

  def update
    @scrape_session = ScrapeSession.find(params[:scrape_session_id])
    @question = Question.find(params[:id])
    if @question.update_attributes(question_params)
      log_question_event @question, "edit"
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
    log_question_event question, "delete"
    flash[:success] = "Question Deleted!"
    redirect_to scrape_session_questions_path
  end

  private

    def question_params
      params.require(:question).permit(:question, :description)
    end

    def log_question_event(question, event)
      event_params = {}
      event_params[:question_id] = question.id
      event_params[:question]    = question.question
      event_params[:event_time]  = Time.now
      event_params[:user_id]     = current_user.id
      event_params[:username]    = current_user.username
      event_params[:event_type]  = event

      log_event = @scrape_session.question_logs.build(event_params)

      if log_event.save
        logger.debug "Question Log : #{event}"
      end 

    end

end
