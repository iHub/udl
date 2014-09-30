class AssignSessionWorker
	include Sidekiq::Worker
	sidekiq_options({ queue: :sessions })

	def perform(id)
		@tweet = TwitterParser::Tweet.find(id) if id
		return false if @tweet.blank?
		@term = TwitterParser::Term.where(title: @tweet.text.split.join(' ').gsub('#', ' ').split.map(&:downcase)).first
		@session = @term.scrape_session if @term.present?
		@tweet.update(scrape_session: @session) if @session.present?
	end
end