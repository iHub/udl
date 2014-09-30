require_dependency "twitter_parser/application_controller"

module TwitterParser
  class TermsController < ApplicationController
    before_action :set_term, only: [:show, :edit, :update, :destroy]

    # GET /terms
    def index
      @terms = Term.all
    end

    # GET /terms/1
    def show
    end

    # GET /terms/new
    def new
      return redirect_to (request.referrer || root_url), alert: "You have to specify a scrape session to create a term" unless request.url.scan("?ref=").present?
      @term = Term.new
      @id = request.url.split("?ref=").last
      scrape_session = ScrapeSession.find("#{@id}")
      @title = "New question for #{scrape_session.name}"
      session[:scrape_session] = @id      
    end

    # GET /terms/1/edit
    def edit
    end

    # POST /terms
    def create
      scrape_session = ScrapeSession.find("#{session[:scrape_session]}")
      @term = Term.new(term_params.merge(scrape_session: scrape_session))
      @term.channel = "Umati Twitter"
      if @term.save
        session[:scrape_session] = nil
        redirect_to @term, notice: 'Term was successfully created.'
      else
        render :new
      end
    end

    # PATCH/PUT /terms/1
    def update
      if @term.update(term_params)
        redirect_to @term, notice: 'Term was successfully updated.'
      else
        render :edit
      end
    end

    # DELETE /terms/1
    def destroy
      @term.destroy
      redirect_to terms_url, notice: 'Term was successfully destroyed.'
    end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_term
      @term = Term.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def term_params
      params.require(:term).permit(:title)
    end
  end
end
