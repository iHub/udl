require_dependency "tagger/application_controller"

module Tagger
  class QuestionsController < ApplicationController
    before_action :set_question, only: [:show, :edit, :update, :destroy]

    # GET /questions
    def index
      return redirect_to (request.referrer || root_url) unless request.url.scan("?ref=").present?# or request.referrer.scan("?ref=").present?)
      @id = request.url.split("?ref=").last
      @scrape_session = ScrapeSession.find("#{@id}")
      session[:scrape_session] = @id
      @scrape_session_selected = true

      @questions = @scrape_session.questions
    end

    # GET /questions/1
    def show
    end

    # GET /questions/new
    def new
      return redirect_to (request.referrer || root_url) unless (request.url.scan("?ref=").present? or request.referrer.scan("?ref=").present?)
      @question = Question.new
      request.url.scan("?ref=").present? ? @id = request.url.split("?ref=").last : @id = request.referrer.split("?ref=").last
      @scrape_session = ScrapeSession.find("#{@id}")
      @title = "New question for #{@scrape_session.name}"
      session[:scrape_session] = @id
      @scrape_session_selected = true
    end

    # GET /questions/1/edit
    def edit
    end

    # POST /questions
    def create
      @scrape_session = ScrapeSession.find("#{session[:scrape_session]}")
      @question = Question.new(question_params.merge(scrape_session: @scrape_session))
      @scrape_session_selected = true

      if @question.save
        redirect_to [@question, :assign]#, notice: 'Question was successfully created.'
        session[:scrape_session] = nil
      else
        render :new
      end
    end

    # PATCH/PUT /questions/1
    def update
      if @question.update(question_params)
        redirect_to @question#, notice: 'Question was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /questions/1
    def destroy
      @question.destroy
      redirect_to questions_url#, notice: 'Question was successfully destroyed.'
    end

    def assign
      @question =  Question.find(params[:question_id])
      if request.method == "GET"
        @title = "Assign Question to member"
      elsif request.method == "POST"
        return redirect_to (request.referrer || back), alert: "Tagger has to be present" if params[:question][:user_ids].reject!(&:blank?).blank?
        Question.assign_records_to_user(params)
        # @question.assign_question_to_taggers(params[:question][:tag_number])
        redirect_to tagger.questions_url, notice: "Question tagged successfully"
      end
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_question
        @question = Question.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def question_params
        params.require(:question).permit!#(:content, :scrape_session_id)
      end
  end
end
