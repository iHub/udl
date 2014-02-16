class AnswersController < ApplicationController

  def index
    
    @page_number = params[:page]

    if !params[:scrape_session_id].nil?
        @scrape_session = get_scrape_session(params[:scrape_session_id])
        @answers = @scrape_session.answers.paginate(:page => params[:page])   
        @answer_scope = "session"
    elsif !params[:question_id].nil?
        @question = Question.find(params[:question_id])
        @answers = @question.answers.paginate(:page => params[:page])
        @answer_scope = "question"
    end
  end

  def edit
    @scrape_session = get_scrape_session(params[:scrape_session_id])
    @question = Question.find(params[:question_id])
  	@answer = @question.answers.find(params[:id])
  end

  def new
    @scrape_session = get_scrape_session(params[:scrape_session_id])
    @question = Question.find(params[:question_id])
  	@answer = @question.answers.build
  end

  def create
    @scrape_session = get_scrape_session(params[:scrape_session_id])
    @question = Question.find(params[:question_id])
  	@answer = @question.answers.build(answer_params)
  	if @answer.save
      log_answer_event @question, @answer, "create"
  		flash[:success] = "Answer created!" 
      redirect_to scrape_session_question_answers_path
  	else
  		render 'new'
  	end
  end

  def update
    @scrape_session = get_scrape_session(params[:scrape_session_id])    
    @question       = @scrape_session.questions.find(params[:question_id])
    @answer         = @question.answers.find(params[:id])

    if @answer.update_attributes(answer_params)
      log_answer_event @question, @answer, "edit"
      flash[:success] = "Your Question has been updated."
      redirect_to scrape_session_question_answer_path(@scrape_session, @question, @answer)
    else
      render edit_scrape_session_question_answer_path(@answer)
    end
  end

  def show
    @scrape_session = get_scrape_session(params[:scrape_session_id])
    @question = Question.find(params[:question_id])
  	@answer = @question.answers.find(params[:id])
  end

  def destroy
    @scrape_session = get_scrape_session(params[:scrape_session_id])
    question = Question.find(params[:question_id])
  	answer = question.answers.find(params[:id]).destroy
    log_answer_event question, answer, "delete"
    flash[:success] = "Answer Deleted!"
    redirect_to scrape_session_question_answers_path
  end

  private

    def answer_params
      params.require(:answer).permit(:answer, :description)
    end

    def log_answer_event(question, answer, event)
      event_params = {}
      event_params[:answer_id]   = answer.id
      event_params[:answer]      = answer.answer
      event_params[:question_id] = question.id
      event_params[:question]    = question.question
      event_params[:event_time]  = Time.now
      event_params[:user_id]     = current_user.id
      event_params[:username]    = current_user.username
      event_params[:event_type]  = event

      log_event = @scrape_session.answer_logs.build(event_params)

      if log_event.save
        logger.debug "Answer Log : #{event}"
      end 

    end

end
